from pathlib import Path
from dagster_dbt import DbtProject

DBT_PROJECT_DIR = Path(__file__).joinpath("..", "..", "..", "dp-dbt").resolve()

dbt_project = DbtProject(
    project_dir=DBT_PROJECT_DIR,
)
