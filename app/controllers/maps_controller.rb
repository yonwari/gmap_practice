class MapsController < ApplicationController
  before_action :set_map, only: [:show, :edit, :update, :destroy]
  require 'dotenv'

  # GET /maps
  # GET /maps.json
  def index
    @maps = Map.all
  end

  # GET /maps/1
  # GET /maps/1.json
  def show
      # 一箇所のとき
    # @map = Map.find_by(id:params[:id])
    # @latitude = @map.latitude
    # @longitude = @map.longitude
    # @address = @map.address
    @key = ENV['GMAP_API_KEY']

    @maps = Map.all
    @maps_ary = []
    @maps.each do |map|
      @maps_ary << [map.address, map.latitude, map.longitude]
    end
    p @maps_ary
  end

  # GET /maps/new
  def new
    @map = Map.new
  end

  # GET /maps/1/edit
  def edit
  end

  # POST /maps
  # POST /maps.json
  def create
    @map = Map.new(map_params)
    
    # API呼び出し、緯度経度を代入
    require 'net/https'
    require 'json'
    require 'uri'

    address = URI.encode(@map.address)
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{address}&key=AIzaSyAY1XPb1rDLqacdy_iDfrppVxWmwNdzZ0E")
    http = Net::HTTP.new(uri.host, uri.port)
    json = Net::HTTP.get(uri)
    result = JSON.parse(json, {:symbolize_names => true})
    @map.latitude = result[:results][0][:geometry][:location][:lat]
    @map.longitude = result[:results][0][:geometry][:location][:lng]

    respond_to do |format|
      if @map.save
        format.html { redirect_to @map, notice: 'Map was successfully created.' }
        format.json { render :show, status: :created, location: @map }
      else
        format.html { render :new }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /maps/1
  # PATCH/PUT /maps/1.json
  def update
    respond_to do |format|
      if @map.update(map_params)
        format.html { redirect_to @map, notice: 'Map was successfully updated.' }
        format.json { render :show, status: :ok, location: @map }
      else
        format.html { render :edit }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maps/1
  # DELETE /maps/1.json
  def destroy
    @map.destroy
    respond_to do |format|
      format.html { redirect_to maps_url, notice: 'Map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.require(:map).permit(:address, :latitude, :longitude)
    end
end
