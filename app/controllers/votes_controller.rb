class VotesController < ApplicationController
  before_action :set_vote, only: [:show, :edit, :update, :destroy]

  # GET /votes
  # GET /votes.json
  def index
    @votes = Vote.all
    @prabowo_sum = @votes.sum(:prabowo_count)
    @jokowi_sum = @votes.sum(:jokowi_count)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vote
      @vote = Vote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vote_params
      params.require(:vote).permit(:grand_parent_id, :parent_id, :prabowo_count, :jokowi_count)
    end
end
