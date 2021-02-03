class HomeController < ApplicationController
  def index
    render plain: "VTEX Sync is up and running!\n#{Time.current}"
  end
end
