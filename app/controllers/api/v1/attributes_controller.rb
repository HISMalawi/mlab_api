# frozen_string_literal: true

module Api
  module V1
    # Controller for managing generic attributes
    class AttributesController < ApplicationController
      before_action :set_attribute, only: %i[show update destroy]

      # GET /api/v1/attributes
      def index
        @attributes = if params[:field_type].present?
                        Attribute.active.by_field_type(params[:field_type])
                      else
                        Attribute.active
                      end

        render json: @attributes
      end

      # GET /api/v1/attributes/:id
      def show
        render json: @attribute
      end

      # POST /api/v1/attributes
      def create
        @attribute = Attribute.new(attribute_params)
        @attribute.creator = User.current&.id
        @attribute.created_date = Time.current
        @attribute.updated_by = User.current&.id
        @attribute.updated_date = Time.current

        if @attribute.save
          render json: @attribute, status: :created
        else
          render json: { errors: @attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/attributes/:id
      def update
        @attribute.updated_by = User.current&.id
        @attribute.updated_date = Time.current

        if @attribute.update(attribute_params)
          render json: @attribute
        else
          render json: { errors: @attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/attributes/:id (soft delete/void)
      def destroy
        @attribute.voided = 1
        @attribute.voided_by = User.current&.id
        @attribute.voided_date = Time.current
        @attribute.voided_reason = params[:reason] || 'Deleted by user'

        if @attribute.save
          render json: { message: 'Attribute deleted successfully' }
        else
          render json: { errors: @attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_attribute
        @attribute = Attribute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Attribute not found' }, status: :not_found
      end

      def attribute_params
        params.require(:attribute).permit(
          :name,
          :label,
          :description,
          :field_type,
          :active,
          options: []
        )
      end
    end
  end
end
