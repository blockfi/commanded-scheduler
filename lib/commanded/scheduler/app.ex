defmodule Commanded.Scheduler.App do
  use Commanded.Application,
    otp_app: :commanded_scheduler,
    event_store: [
      adapter: Commanded.EventStore.Adapters.InMemory
    ],
    pub_sub: :local,
    registry: :local

  router(Commanded.Scheduler.Router)
end
