# in app/controllers/movies_controller.rb
class InvalidFilterSortError < StandardError ; end
class MoviesController < ApplicationController
  def index
	@all_ratings = Movie.all_ratings
	#ensure that there is either new sorting input or the old sorting settings are used
	if params == nil && session == nil
		@first = true
	end
	if params[:sort] != nil
		@sort = params[:sort]
	else
		@sort = session[:sort]
		@redirect = true
	end
	session[:sort] = @sort
	#ensure that there is new ratings input or old ratings in session[] else no filters
	if params[:ratings] == nil && session[:ratings] == nil #no new or old filters
		@selected_ratings = Movie.all_ratings
		session[:ratings] = Hash[@selected_ratings.map {|i| [i, true]}]
		@redirect = true
	elsif params[:ratings] == nil && session[:ratings] != nil #for all boxes unchecked case
		@selected_ratings = session[:ratings].keys
		@redirect = true
	elsif params[:ratings] != nil #if new filters
		@selected_ratings = params[:ratings].keys
		session[:ratings] = params[:ratings]
	else #if no new filters 
		@selected_ratings = session[:ratings].keys
		@redirect = true
	end
	#ensure that inputs are valid
	if (@sort == nil || @sort == 'title' || @sort == 'release_date') && ((@selected_ratings & @all_ratings) == @selected_ratings)
		#if a filter or sort gets re-used, we must redirect with both inputs filled so that all info is present in the URI
		if @redirect == true && @first == false
			flash.keep
			redirect_to movies_path(:sort => @sort, :ratings => session[:ratings])
		end
		@movies = Movie.find_all_by_rating(@selected_ratings, :order => @sort)
		if (@sort == 'title')
			@title_class = 'hilite'
		elsif (@sort == 'release_date')
			@release_date_class = 'hilite'
		end
	#else 
	else
		raise InvalidFilterSortError
	end
  end

  def show
    id = params[:id]
    @movie = Movie.find(id)
    # will render app/views/movies/show.html.haml by default
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end
