defmodule CircularlyWeb.Components.ButtonTest do
  use CircularlyWeb.SurfaceCase

  alias CircularlyWeb.Components.Button

  test "renders a default primary button" do
    html =
      render_surface do
        ~F"""
        <Button>
          Action
        </Button>
        """
      end

    assert html =~ """
           <button type="submit" class="flex border rounded-md shadow-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 border-transparent text-white bg-teal-600 hover:bg-teal-700 px-4 py-2 text-base items-center">
             Action
           </button>
           """
  end

  test "ignores invalid attribute values" do
    html =
      render_surface do
        ~F"""
        <Button color="invalid" size="invalid" width="invalid" type="invalid">
          Action
        </Button>
        """
      end

    assert html =~ """
           <button type="submit" class="flex border rounded-md shadow-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 border-transparent text-white bg-teal-600 hover:bg-teal-700 px-4 py-2 text-base items-center">
             Action
           </button>
           """
  end

  test "renders a secondary xs sized full-width button with custom additional class and button type reset" do
    html =
      render_surface do
        ~F"""
        <Button color="secondary" size="xs" width="full" class="custom-class" type="reset">
          Action
        </Button>
        """
      end

    assert html =~ """
           <button type="reset" class="custom-class flex border rounded-md shadow-sm font-medium focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-teal-500 border-transparent text-teal-700 bg-teal-100 hover:bg-teal-200 px-2.5 py-1.5 text-xs w-full justify-center">
             Action
           </button>
           """
  end
end
