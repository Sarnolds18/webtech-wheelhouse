module Repairs
  # One intake photo of a repair, removed on its own from the repair's page or its edit page.
  class PhotosController < ApplicationController
    def destroy
      repair = Repair.find(params[:repair_id])
      photo = repair.photos.find(params[:id])
      photo.purge

      redirect_back_or_to repair, notice: "A photo was removed from repair ##{repair.id}.", status: :see_other
    end
  end
end
