"""Main CLI module for the ThreatOS Application Manager."""

import logging
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

import click
from rich.console import Console
from rich.logging import RichHandler
from rich.progress import (
    BarColumn,
    Progress,
    SpinnerColumn,
    TextColumn,
    TimeElapsedColumn,
)

from ...core import ApplicationManager
from ...core.exceptions import AppManagerError
from ...utils.logging import setup_logging, LoggingContext

# Configure rich console
console = Console()

# Set up logging
logger = logging.getLogger(__name__)

@click.group(invoke_without_command=True)
@click.option(
    '--log-level',
    type=click.Choice(['debug', 'info', 'warning', 'error', 'critical'], case_sensitive=False),
    default='info',
    help='Set the logging level.',
    show_default=True,
)
@click.option(
    '--log-file',
    type=click.Path(dir_okay=False, writable=True, path_type=Path),
    help='Log file path.',
)
@click.option(
    '--config-dir',
    type=click.Path(file_okay=False, dir_okay=True, writable=True, path_type=Path),
    default=Path.home() / ".config" / "threatos" / "apps",
    help='Configuration directory for applications.',
    show_default=True,
)
@click.version_option()
@click.pass_context
def cli(
    ctx: click.Context,
    log_level: str,
    log_file: Optional[Path],
    config_dir: Path,
) -> None:
    """ThreatOS Application Manager - Manage containerized applications."""
    # Set up logging
    setup_logging(level=log_level, log_file=log_file)
    
    # Create a context object to pass to subcommands
    ctx.ensure_object(dict)
    ctx.obj['CONFIG_DIR'] = config_dir
    
    # If no command is provided, show help
    if ctx.invoked_subcommand is None:
        click.echo(ctx.get_help())
        ctx.exit(0)

@cli.command()
@click.argument('app_id')
@click.option(
    '--runtime',
    type=click.Choice(['docker', 'podman'], case_sensitive=False),
    help='Container runtime to use.',
)
@click.option(
    '--detach/--no-detach',
    default=True,
    help='Run containers in the background.',
    show_default=True,
)
@click.pass_context
def start(
    ctx: click.Context,
    app_id: str,
    runtime: Optional[str],
    detach: bool,
) -> None:
    """Start an application."""
    try:
        with Progress(
            SpinnerColumn(),
            "[progress.description]{task.description}",
            BarColumn(),
            "[progress.percentage]{task.percentage:>3.0f}%",
            TimeElapsedColumn(),
            console=console,
            transient=True,
        ) as progress:
            task = progress.add_task(f"Starting {app_id}...", total=1)
            
            try:
                app_mgr = ApplicationManager(config_dir=ctx.obj['CONFIG_DIR'])
                app_mgr.start_application(app_id, runtime=runtime, detach=detach)
                progress.update(task, completed=1)
                console.print(f"[green]✓[/] Application '{app_id}' started successfully")
            except Exception as e:
                progress.stop()
                console.print(f"[red]✗[/] Failed to start application: {e}", err=True)
                sys.exit(1)
    except KeyboardInterrupt:
        console.print("\n[yellow]Operation cancelled by user[/]")
        sys.exit(130)  # 128 + SIGINT

@cli.command()
@click.argument('app_id')
@click.option(
    '--timeout',
    type=int,
    default=10,
    help='Timeout in seconds to wait for the application to stop.',
    show_default=True,
)
@click.pass_context
def stop(
    ctx: click.Context,
    app_id: str,
    timeout: int,
) -> None:
    """Stop a running application."""
    try:
        app_mgr = ApplicationManager(config_dir=ctx.obj['CONFIG_DIR'])
        app_mgr.stop_application(app_id, timeout=timeout)
        console.print(f"[green]✓[/] Application '{app_id}' stopped successfully")
    except Exception as e:
        console.print(f"[red]✗[/] Failed to stop application: {e}", err=True)
        sys.exit(1)

@cli.command()
@click.argument('source', type=click.Path(exists=True, file_okay=True, dir_okay=True, path_type=Path))
@click.option(
    '--runtime',
    type=click.Choice(['docker', 'podman'], case_sensitive=False),
    help='Container runtime to use for installation.',
)
@click.pass_context
def install(
    ctx: click.Context,
    source: Path,
    runtime: Optional[str],
) -> None:
    """Install an application from a source directory or archive."""
    try:
        app_mgr = ApplicationManager(config_dir=ctx.obj['CONFIG_DIR'])
        app = app_mgr.install_application(source, runtime=runtime)
        console.print(f"[green]✓[/] Application '{app.id}' installed successfully")
    except Exception as e:
        console.print(f"[red]✗[/] Failed to install application: {e}", err=True)
        sys.exit(1)

@cli.command()
@click.argument('app_id')
@click.option(
    '--remove-data/--keep-data',
    default=False,
    help='Remove application data when uninstalling.',
    show_default=True,
)
@click.pass_context
def uninstall(
    ctx: click.Context,
    app_id: str,
    remove_data: bool,
) -> None:
    """Uninstall an application."""
    try:
        app_mgr = ApplicationManager(config_dir=ctx.obj['CONFIG_DIR'])
        if app_mgr.uninstall_application(app_id, remove_data=remove_data):
            console.print(f"[green]✓[/] Application '{app_id}' uninstalled successfully")
        else:
            console.print(f"[yellow]![/] Application '{app_id}' not found or already uninstalled")
    except Exception as e:
        console.print(f"[red]✗[/] Failed to uninstall application: {e}", err=True)
        sys.exit(1)

@cli.command()
@click.option(
    '--all',
    is_flag=True,
    help='Show all applications, including system ones.',
)
@click.pass_context
def list_apps(
    ctx: click.Context,
    all: bool,
) -> None:
    """List installed applications."""
    try:
        app_mgr = ApplicationManager(config_dir=ctx.obj['CONFIG_DIR'])
        # TODO: Implement application listing
        console.print("List of installed applications:")
        console.print("  - app1")
        console.print("  - app2")
    except Exception as e:
        console.print(f"[red]✗[/] Failed to list applications: {e}", err=True)
        sys.exit(1)

def main() -> None:
    """Entry point for the CLI."""
    try:
        cli(obj={})
    except AppManagerError as e:
        console.print(f"[red]Error:[/] {e}", err=True)
        sys.exit(1)
    except KeyboardInterrupt:
        console.print("\n[yellow]Operation cancelled by user[/]")
        sys.exit(130)  # 128 + SIGINT
    except Exception as e:
        console.print(f"[red]Unexpected error:[/] {e}", err=True)
        if logger.isEnabledFor(logging.DEBUG):
            import traceback
            console.print(traceback.format_exc())
        sys.exit(1)

if __name__ == "__main__":
    main()
