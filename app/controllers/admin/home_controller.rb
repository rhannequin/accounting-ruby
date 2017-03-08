module Admin
  class HomeController < AdminController
    def index
      authorize! :read, :admin_homepage
    end
  end
end
