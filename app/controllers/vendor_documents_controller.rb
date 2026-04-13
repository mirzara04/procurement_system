class VendorDocumentsController < ApplicationController
  before_action :set_vendor, only: [:new, :create]
  before_action :set_document, only: [:show, :destroy]

  def new
    @document = @vendor.vendor_documents.build
    authorize @document
  end

  def create
    @document = @vendor.vendor_documents.build(document_params)
    @document.uploaded_by = current_user
    authorize @document

    if @document.save
      redirect_to @vendor, notice: 'Document uploaded successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    authorize @document
    redirect_to rails_blob_path(@document.file, disposition: 'attachment') if @document.file.attached?
  end

  def destroy
    authorize @document
    vendor = @document.vendor
    @document.destroy
    redirect_to vendor, notice: 'Document removed.'
  end

  private

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id])
  end

  def set_document
    @document = VendorDocument.find(params[:id])
  end

  def document_params
    params.require(:vendor_document).permit(
      :document_type, :document_number, :issue_date, :expiry_date, :notes, :file
    )
  end
end
