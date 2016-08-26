require 'opencv'
include OpenCV

class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
    data = './cascade/haarcascade_frontalface_alt.xml'
    detector = CvHaarClassifierCascade::load(data)
    image = IplImage.load("./public#{@product.image}")

    detector.detect_objects(image).each do |region|
      color = CvColor::Gray
      image.rectangle! region.top_left, region.bottom_right, :color => color #ここで顔に枠をつけるよ
      image.set_roi(region) #ここでさらに顔の部分だけを切り取り
    end

    i3 = image.BGR2GRAY.add(10) #グレスケ
    i2 = i3.threshold(128, 255, CV_THRESH_BINARY) #2値化
# i2.save_image(ARGV[1])

    black =  i2.count_non_zero
    size = i2.width * i2.height
    white = size.to_f - black

    @artistry = (1 - (black * 0.8) / (size / 2.0)) * 100.0
    @technical = (1 - (white / black)) * 10.0
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :image)
    end
end
