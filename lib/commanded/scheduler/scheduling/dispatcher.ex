defmodule Commanded.Scheduler.Dispatcher do
  @moduledoc false

  require Logger

  @behaviour Commanded.Scheduler.Job

  def execute(schedule_uuid, command) do
    Logger.debug(fn -> "Attempting to trigger schedule #{inspect(schedule_uuid)}" end)

    Commanded.Scheduler.App.dispatch(command)
  end
end
