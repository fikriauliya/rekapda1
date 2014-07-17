class LocationsController < ApplicationController
  def index
    if params[:province] and params[:kabupaten]
      @view_mode = :kabupaten
      @locations = Location.includes(:kecamatan).select('province_id', 'kabupaten_id', 'kecamatan_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          where(:province_id => params[:province], :kabupaten_id => params[:kabupaten]).
          group(:province_id, :kabupaten_id, :kecamatan_id).
          order(:kecamatan_id)
      @db1s = []

      @province_name = Province.find(params[:province]).name
      @kabupaten_name = Kabupaten.find(params[:kabupaten]).name

      gon.id = params[:kabupaten]
    elsif params[:province]
      @view_mode = :province
      @locations = Location.includes(:kabupaten).select('province_id', 'kabupaten_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          where(:province_id => params[:province]).
          group(:province_id, :kabupaten_id).
          order(:kabupaten_id)

      @db1s = Db1.includes(:kabupaten).select('province_id', 'kabupaten_id',
                                                'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                                'max(last_fetched_at) as max_last_fetched_at',
                                                'count(last_fetched_at) as fetched_count',
                                                'count(*) as total_count').
          where(:province_id => params[:province]).
          group(:province_id, :kabupaten_id).
          order(:kabupaten_id)

      @province_name = Province.find(params[:province]).name

      gon.id = params[:province]
    else
      @view_mode = :national
      @locations = Location.includes(:province).select('province_id',
                                   'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                   'max(last_fetched_at) as max_last_fetched_at',
                                   'count(last_fetched_at) as fetched_count',
                                   'count(*) as total_count').
          group(:province_id).
          order(:province_id)

      @db1s = Db1.includes(:province).select('province_id',
                                             'sum(jokowi_count) as sum_jokowi_count', 'sum(prabowo_count) as sum_prabowo_count',
                                             'max(last_fetched_at) as max_last_fetched_at',
                                             'count(last_fetched_at) as fetched_count',
                                             'count(*) as total_count').
          group(:province_id).
          order(:province_id)

      gon.id = 0
    end

    @prabowo_sum = @locations.inject(0) { |sum, val| sum += val.sum_prabowo_count }
    @jokowi_sum = @locations.inject(0) { |sum, val| sum += val.sum_jokowi_count }
    @fetched_count_sum = @locations.inject(0) { |sum, val| sum += val.fetched_count }
    @total_count_sum = @locations.inject(0) { |sum, val| sum += val.total_count }

    if (params[:province] and params[:kabupaten])
      @prabowo_db1_sum = 0
      @jokowi_db1_sum = 0
      @fetched_db1_count_sum = 0
      @total_db1_count_sum = 0
    else
      @prabowo_db1_sum = @db1s.inject(0) { |sum, val| sum += val.sum_prabowo_count }
      @jokowi_db1_sum = @db1s.inject(0) { |sum, val| sum += val.sum_jokowi_count }
      @fetched_db1_count_sum = @db1s.inject(0) { |sum, val| sum += val.fetched_count }
      @total_db1_count_sum = @db1s.inject(0) { |sum, val| sum += val.total_count }
    end
  end
end
