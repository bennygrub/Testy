class BellsController < ApplicationController
  before_action :set_bell, only: [:show, :edit, :update, :destroy]

  # GET /bells
  # GET /bells.json
  def index
    @bells = Bell.all
  end

  # GET /bells/1
  # GET /bells/1.json
  def show
  end

  # GET /bells/new
  def new
    @bell = Bell.new
  end

  # GET /bells/1/edit
  def edit
  end

  # POST /bells
  # POST /bells.json
  def create
    @bell = Bell.new(bell_params)

    respond_to do |format|
      if @bell.save
        format.html { redirect_to @bell, notice: 'Bell was successfully created.' }
        format.json { render action: 'show', status: :created, location: @bell }
      else
        format.html { render action: 'new' }
        format.json { render json: @bell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bells/1
  # PATCH/PUT /bells/1.json
  def update
    respond_to do |format|
      if @bell.update(bell_params)
        format.html { redirect_to @bell, notice: 'Bell was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @bell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bells/1
  # DELETE /bells/1.json
  def destroy
    @bell.destroy
    respond_to do |format|
      format.html { redirect_to bells_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bell
      @bell = Bell.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bell_params
      params.require(:bell).permit(:user_id, :name, :description)
    end
end
