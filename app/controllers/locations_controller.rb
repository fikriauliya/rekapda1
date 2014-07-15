class LocationsController < ApplicationController
  def index
    if params[:province] and params[:kabupaten]
      @view_mode = :kabupaten
      @locations = Location.select('province_id', 'kabupaten_id', 'kecamatan_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          where(:province_id => params[:province], :kabupaten_id => params[:kabupaten]).
          group(:province_id, :kabupaten_id, :kecamatan_id).
          order(:kecamatan_id)
      @province_name = Province.find(params[:province]).name
      @kabupaten_name = Kabupaten.find(params[:kabupaten]).name
    elsif params[:province]
      @view_mode = :province
      @locations = Location.select('province_id', 'kabupaten_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          where(:province_id => params[:province]).
          group(:province_id, :kabupaten_id).
          order(:kabupaten_id)
      @province_name = Province.find(params[:province]).name
    else
      @view_mode = :national
      @locations = Location.select('province_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          group(:province_id).
          order(:province_id)
    end

    @prabowo_sum = @locations.inject(0) { |sum, val| sum += val.sum_prabowo_count }
    @jokowi_sum = @locations.inject(0) { |sum, val| sum += val.sum_jokowi_count }
    @fetched_count_sum = @locations.inject(0) { |sum, val| sum += val.fetched_count }
    @total_count_sum = @locations.inject(0) { |sum, val| sum += val.total_count }
  end
end
