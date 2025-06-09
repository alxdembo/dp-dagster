from dagster import AssetSelection, build_schedule_from_partitioned_job, define_asset_job
from .sensors.hn_tables_updated_sensor import make_hn_tables_updated_sensor
from datetime import datetime
from dagster import HourlyPartitionsDefinition

CORE = "core"
ACTIVITY_ANALYTICS = "activity_analytics"
RECOMMENDER = "recommender"

hourly_partitions = HourlyPartitionsDefinition(start_date=datetime(2020, 12, 1))
activity_analytics_assets_sensor = make_hn_tables_updated_sensor(
    # selecting by group allows us to include the activity_analytics assets that are defined in dbt
    define_asset_job("activity_analytics_job", selection=AssetSelection.groups(ACTIVITY_ANALYTICS))
)

recommender_assets_sensor = make_hn_tables_updated_sensor(
    define_asset_job("story_recommender_job", selection=AssetSelection.groups(RECOMMENDER))
)

core_assets_schedule = build_schedule_from_partitioned_job(
    define_asset_job(
        "core_job",
        selection=AssetSelection.groups(CORE),
        tags={
            "dagster-k8s/config": {
                "container_config": {
                    "resources": {
                        "requests": {"cpu": "500m", "memory": "2Gi"},
                    }
                },
            }
        },
        partitions_def=hourly_partitions,
    )
)
