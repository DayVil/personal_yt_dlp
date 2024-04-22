defmodule PersonalYtDlpWeb.DownloadLive.FormComponent do
  use PersonalYtDlpWeb, :live_component

  attr :form, :string, required: true
  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-submit="submit">
        <div class="flex gap-2 items-end">
          <div class="grow">
            <.input field={@form[:url]} type="text" label="URL" />
          </div>

          <button class="bg-black border border-black text-white hover:bg-gray-700 font-semibold py-2 px-3 rounded-md">Create</button>
        </div>
      </.form>
    </div>
    """
  end
end
