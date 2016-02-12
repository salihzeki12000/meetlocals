class HostsController < ApplicationController
    require 'pp'
    include ImagesHelper
	  before_action :set_host, only: [:show, :edit, :update, :destroy, :update_host_profile, :update_holiday]

  def index
		limit_per_page = 3
		session[:seed] ||= rand(10).round(2) / 10
		Host.connection.execute("select setseed(#{session[:seed]})")

    if (request.request_method == 'GET')
			@hosts = Host.where(approved: true).order('random()').includes(:images)
		elsif (request.request_method == 'POST')
      assign_search_inputs!
			# age_range = /(\d+)\W?(\d+)?/.match(search_params[:age_range])
			# age_range ||= [nil, 0, 200]
      # debugger

			# @hosts = Host.where(approved: true).search(age_range[1], age_range[2], @selected_location, @selected_group, @selected_date).paginate(page:params[:page], per_page: limit_per_page)
      @hosts = Host.search_by(search_params).includes(:images)
		end

		respond_to do |format|
	  	# format.html
	  	format.js
		end unless params[:page].nil?

  end

  def show
    @normal_events = @host.experiences.normal_events
		@special_events = @host.experiences.special_events
    @response = check_images_host(@host.id)
    @paid_exp = @host.bookings.where(status: 'completed').pluck(:group_size)
    respond_to do |format|
      format.js    { render json: @response }
      format.html
    end
  end

  def new
    @host = Host.new
  end

  def edit
  end

  # POST /hosts
  # We don't seem to be using this...
  def create
    # @host = Host.new(host_detail_params)

    # @image_file = params[:host].delete(:image_file)

    # respond_to do |format|
    #   if @host.save
    #     format.html { redirect_to host, notice: 'host was successfully created.' }

    #     # Create image after parent-host is saved
    #     new_img = @host.images.new
    #     new_img.image_file = @image_file
    #     new_img.caption = @image_file.original_filename
    #     new_img.save!
    #     new_img.update(imageable:@host)
    #   else
    #     format.html { render :new }
    #   end
    # end
  end

  # PATCH/PUT /hosts/1
  def update
    # this commit param apparently is the name of the f.submit button
    if params[:commit] == "Approve User"
      @host.update(approved: true)
      Hostmailer.host_approved(@host.id).deliver_later
      redirect_to(:back)
    else
      params[:host][:video_url].gsub!(/watch\?v=/,"embed/")
      @image_file = params[:host].delete(:image_file)
      @host.update(host_params.except(:image_file))
      if @image_file.present?
        if @host.images.present?
          @host.images.delete_all
        end
        Image.create(local_image: @image_file, caption: @image_file.original_filename, imageable: @host)
      end
      # this is so email will be sent only while admin needs to know
      if @host.approved == false
        puts current_host
        puts current_admin
        redirect_to create_host_success_path if current_host
        redirect_to admins_path, notice: "Update has been successful" if current_admin
      else
        if current_host
          redirect_to host_path(@host), notice: 'Your host profile was successfully updated.'
        else
          redirect_to admins_path, notice: "Update has been successful"
        end
      end
    end
  end

  # DELETE /hosts/1
  def destroy
    email = @host.email
    if @host.images.present?
      @host.images.delete_all
    end
    @host.experiences.each do |exp|
        exp.bookings.delete_all
    end
    @host.experiences.delete_all
    @host.notifications.delete_all
    approved = @host.approved
    @host.delete
    if current_admin && approved == false
      Hostmailer.host_rejected(email).deliver_later
      redirect_to admin_settings_path
    elsif current_admin && approved == true
      redirect_to admins_path
    else
      respond_to do |format|
        format.html { redirect_to admins_url, notice: 'host was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  end

  def edit_host_profile # Edit profile page
  	if current_host == nil && current_admin == nil
  	  deny_access_host
    else
      @host = Host.find(params[:id])
    end
  end

  def update_host_profile # Create and Edit host profile

    @image_file = params[:host].delete(:image_file)
    if @image_file.present?
      if @host.images.present?
        @host.images.delete_all
      end
      Image.create(local_image: @image_file, caption: @image_file.original_filename, imageable: @host)
    end
    puts "preparing for host update"
    if @host.update(host_params.except(:image_file))
      puts "updating host"
      respond_to do |format|
        format.html { redirect_to edit_host_profile, notice: 'host profile was successfully updated.' }
      end
    end
  end

	def update_holiday
		holiday = params[:holiday][:dates]

		# redirect_to host_path if @host.set_holiday(holiday)

		respond_to do |format|
			format.js
		end if @host.set_holiday(holiday)
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_host
      @host = Host.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def host_params
      params.require(:host).permit(:username, :email, :password, :password_confirmation, :country, :state, :image_file, :occupation, :interests, :smoker,:pets, :suburb, :latitude, :zip,
       :longitude, :title, :first_name, :last_name, :languages, :street_address, :host_presentation, :neighbourhood, :dob, :video_url, :phone,:registration_number, :bank_name, :bank_number)
    end

    def search_params
      params.require(:search).permit(:date, :age_range, :max_group, :location)
    end

    def assign_search_inputs!
      @selected_age = search_params[:age_range]
      @selected_location = search_params[:location]
      @selected_group = search_params[:max_group]
      @selected_date = search_params[:date]
    end

end
