class QueuesController < ApplicationController
  
  def destroy
    @queue = Sidekiq::Queue.new(params[:id])
    @queue.clear
    
    redirect_to(:back, :notice => "Alle Jobs in Queue #{params[:id]} wurden gelöscht.")
  end
end
