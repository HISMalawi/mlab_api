# frozen_string_literal: true

module Api
  module V1
    # Controller for managing test attribute values
    class TestAttributeValuesController < ApplicationController
      before_action :set_test, only: %i[index create bulk_save]
      before_action :set_test_attribute_value, only: %i[show update destroy]

      # GET /api/v1/tests/:test_id/attribute_values
      def index
        @attribute_values = TestAttributeValue.values_for_test(@test.id)
        render json: @attribute_values
      end

      # GET /api/v1/test_attribute_values/:id
      def show
        render json: @test_attribute_value.as_json(include_attribute: true, include_test: true)
      end

      # POST /api/v1/tests/:test_id/attribute_values
      def create
        @test_attribute_value = TestAttributeValue.new(test_attribute_value_params)
        @test_attribute_value.test_id = @test.id
        @test_attribute_value.creator = User.current&.id
        @test_attribute_value.created_date = Time.current
        @test_attribute_value.updated_by = User.current&.id
        @test_attribute_value.updated_date = Time.current

        if @test_attribute_value.save
          render json: @test_attribute_value.as_json(include_attribute: true), status: :created
        else
          render json: { errors: @test_attribute_value.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/tests/:test_id/attribute_values/bulk_save
      # Bulk create or update multiple attribute values for a test
      def bulk_save
        attributes_data = params[:attributes] || {}

        return render json: { error: 'No attributes provided' }, status: :unprocessable_entity if attributes_data.blank?

        result = TestAttributeValue.save_test_attributes(@test.id, attributes_data)

        if result[:errors].empty?
          render json: {
            message: 'Attributes saved successfully',
            saved: result[:saved].count,
            attributes: TestAttributeValue.values_for_test(@test.id)
          }, status: :ok
        else
          render json: {
            message: 'Some attributes failed to save',
            saved: result[:saved].count,
            errors: result[:errors]
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/test_attribute_values/:id
      def update
        @test_attribute_value.updated_by = User.current&.id
        @test_attribute_value.updated_date = Time.current

        if @test_attribute_value.update(test_attribute_value_params)
          render json: @test_attribute_value.as_json(include_attribute: true)
        else
          render json: { errors: @test_attribute_value.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/test_attribute_values/:id (soft delete/void)
      def destroy
        @test_attribute_value.voided = 1
        @test_attribute_value.voided_by = User.current&.id
        @test_attribute_value.voided_date = Time.current
        @test_attribute_value.voided_reason = params[:reason] || 'Deleted by user'

        if @test_attribute_value.save
          render json: { message: 'Attribute value deleted successfully' }
        else
          render json: { errors: @test_attribute_value.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_test
        @test = Test.find(params[:test_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Test not found' }, status: :not_found
      end

      def set_test_attribute_value
        @test_attribute_value = TestAttributeValue.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Test attribute value not found' }, status: :not_found
      end

      def test_attribute_value_params
        params.require(:test_attribute_value).permit(
          :attribute_id,
          :value
        )
      end
    end
  end
end
