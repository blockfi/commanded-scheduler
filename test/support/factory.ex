defmodule Commanded.Scheduler.Factory do
  @moduledoc false

  alias Commanded.Scheduler.ExampleCommand
  alias Commanded.Scheduler.{CancelSchedule, ScheduleOnce, ScheduleRecurring, TriggerSchedule}
  alias Commanded.Scheduler.Router
  alias ExampleDomain.TicketBooking.Commands.{ReserveTicket, TimeoutReservation}
  alias ExampleDomain.TicketRouter

  def schedule_once(context) do
    schedule_uuid = UUID.uuid4()
    schedule_name = "timeout_reservation"
    ticket_uuid = Map.get(context, :ticket_uuid, UUID.uuid4())
    due_at = NaiveDateTime.utc_now() |> add_minutes(10) |> NaiveDateTime.truncate(:second)

    command = %TimeoutReservation{
      ticket_uuid: ticket_uuid
    }

    schedule_once = %ScheduleOnce{
      schedule_uuid: schedule_uuid,
      name: schedule_name,
      command: command,
      due_at: due_at
    }

    :ok = Commanded.Scheduler.App.dispatch(schedule_once)

    [
      schedule_uuid: schedule_uuid,
      schedule_name: schedule_name,
      schedule_once: schedule_once,
      ticket_uuid: ticket_uuid,
      due_at: due_at,
      command: command
    ]
  end

  def schedule_recurring(_context) do
    schedule_uuid = UUID.uuid4()
    schedule_name = "example"
    aggregate_uuid = UUID.uuid4()
    schedule = "@daily"

    command = %ExampleCommand{
      aggregate_uuid: aggregate_uuid,
      data: "example"
    }

    schedule_recurring = %ScheduleRecurring{
      schedule_uuid: schedule_uuid,
      name: schedule_name,
      command: command,
      schedule: schedule
    }

    :ok = Commanded.Scheduler.App.dispatch(schedule_recurring)

    [
      schedule_uuid: schedule_uuid,
      schedule_name: schedule_name,
      schedule_recurring: schedule_recurring,
      aggregate_uuid: aggregate_uuid,
      command: command,
      schedule: schedule
    ]
  end

  def trigger_schedule(context) do
    %{schedule_uuid: schedule_uuid, schedule_name: name} = context

    trigger_schedule = %TriggerSchedule{schedule_uuid: schedule_uuid, name: name}

    :ok = Commanded.Scheduler.App.dispatch(trigger_schedule)

    []
  end

  def cancel_schedule(context) do
    cancel_schedule = %CancelSchedule{
      schedule_uuid: context.schedule_uuid,
      name: context.schedule_name
    }

    :ok = Commanded.Scheduler.App.dispatch(cancel_schedule)

    []
  end

  def reserve_ticket(context) do
    ticket_uuid = Map.get(context, :ticket_uuid) || UUID.uuid4()
    expires_at = NaiveDateTime.utc_now() |> add_minutes(10)

    reserve_ticket = %ReserveTicket{
      ticket_uuid: ticket_uuid,
      description: "Cinema ticket",
      price: 10.0,
      expires_at: expires_at
    }

    :ok = Commanded.Scheduler.App.dispatch(reserve_ticket)

    [
      ticket_uuid: ticket_uuid,
      schedule_uuid: "schedule-" <> ticket_uuid,
      schedule_name: "@default0",
      expires_at: expires_at,
      due_at: expires_at
    ]
  end

  defp add_minutes(date, minutes) do
    NaiveDateTime.add(date, 60 * minutes, :second)
  end
end
