defmodule CircularlyWeb.Components.AuthLayoutTest do
  use CircularlyWeb.SurfaceCase

  alias CircularlyWeb.Components.AuthLayout

  test "renders an auth layout without header" do
    html =
      render_surface do
        ~F"""
        <AuthLayout>My Layout</AuthLayout>
        """
      end

    assert html =~ """
           <div class="min-h-full flex flex-col justify-center py-12 sm:px-6 lg:px-8">
             <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
               <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
                 My Layout
               </div>
             </div>
           </div>
           """
  end

  test "renders an auth layout with header" do
    html =
      render_surface do
        ~F"""
        <AuthLayout>
        <:header>My Header</:header>
            My Layout
        </AuthLayout>
        """
      end

    assert html =~ """
           <div class="min-h-full flex flex-col justify-center py-12 sm:px-6 lg:px-8">
             <div class="sm:mx-auto sm:w-full sm:max-w-md">
             My Header
             </div>
             <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
               <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
               My Layout
               </div>
             </div>
           </div>
           """
  end
end
