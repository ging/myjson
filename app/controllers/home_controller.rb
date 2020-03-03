class HomeController < ApplicationController

  rescue_from ActionController::ParameterMissing, with: :param_missing

  def index
    @bins_count = Rails.cache.read("bins_count");
    if (!@bins_count) 
        @bins_count = Bin.count
        Rails.cache.write("bins_count", @bins_count)
    end
  end

  def create
      begin
        data = Hash.new
        data["data"] = JSON.parse(bin_params)
        @bin = Bin.new(data)
        @bin.save
        respond_to do |format|
          format.html {redirect_to(bin_path(:id => @bin.encode_id), notice: "Your JSON was saved.")}
        end
      rescue JSON::ParserError => e
        #flash.now[:error] = "JSON parse error: #{e}"
        flash.now[:error] = "Error: Your JSON appears to be invalid."
        render :action => 'index'
      end
  end

  def show
    @bin = Bin.find(decode_id)
  end

  private 

    def bin_params
      params.require(:data)
    end

    def decode_id
      params[:id].to_i(36).to_s.reverse.chop.to_i - 1000
    end

    def param_missing
      flash[:error] = "Enter some JSON before saving."
      redirect_to :back
    end

end
