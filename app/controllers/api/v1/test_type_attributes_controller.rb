# frozen_string_literal: true

module Api
  module V1
    # Controller for managing test type attribute mappings
    class TestTypeAttributesController < ApplicationController
      before_action :set_test_type_attribute, only: %i[show update destroy]
      before_action :set_test_type, only: %i[index create]

      # GET /api/v1/test_types/:test_type_id/attributes
      def index
        include_children = params[:include_children] == 'true'

        # When include_children=true, return only root attributes with nested children
        # This avoids duplication of child attributes at the top level
        if include_children || params[:root_only] == 'true'
          @attributes = TestTypeAttribute.root_attributes_for_test_type(@test_type.id)
          render json: @attributes.map { |tta| tta.as_json(include_children: include_children) }
        else
          # Return all attributes (flat list) when children are not requested
          @attributes = TestTypeAttribute.attributes_for_test_type(@test_type.id, include_children: false)
          render json: @attributes
        end
      end

      # GET /api/v1/test_type_attributes/:id
      def show
        include_children = params[:include_children] == 'true'
        render json: @test_type_attribute.as_json(include_children: include_children)
      end

      # POST /api/v1/test_types/:test_type_id/attributes
      def create
        # Check if a voided record already exists with the same test_type_id and attribute_id
        existing = TestTypeAttribute.unscoped.find_by(
          test_type_id: @test_type.id,
          attribute_id: test_type_attribute_params[:attribute_id]
        )

        if existing&.voided == 1
          # Restore the voided record instead of creating a new one
          existing.voided = 0
          existing.voided_by = nil
          existing.voided_date = nil
          existing.voided_reason = nil
          existing.is_required = test_type_attribute_params[:is_required]
          existing.sort_order = test_type_attribute_params[:sort_order]
          existing.parent_attribute_id = test_type_attribute_params[:parent_attribute_id]
          existing.parent_attribute_value = test_type_attribute_params[:parent_attribute_value]
          existing.test_type_specific_options = test_type_attribute_params[:test_type_specific_options]
          existing.updated_by = User.current&.id
          existing.updated_date = Time.current

          if existing.save
            render json: existing, status: :created
          else
            render json: { errors: existing.errors.full_messages }, status: :unprocessable_entity
          end
        elsif existing
          # Record already exists and is not voided
          render json: { error: 'Attribute is already assigned to this test type' }, status: :unprocessable_entity
        else
          # Create new record
          @test_type_attribute = TestTypeAttribute.new(test_type_attribute_params)
          @test_type_attribute.test_type_id = @test_type.id
          @test_type_attribute.creator = User.current&.id
          @test_type_attribute.created_date = Time.current
          @test_type_attribute.updated_by = User.current&.id
          @test_type_attribute.updated_date = Time.current

          if @test_type_attribute.save
            render json: @test_type_attribute, status: :created
          else
            render json: { errors: @test_type_attribute.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      # PATCH/PUT /api/v1/test_type_attributes/:id
      def update
        @test_type_attribute.updated_by = User.current&.id
        @test_type_attribute.updated_date = Time.current

        if @test_type_attribute.update(test_type_attribute_params)
          render json: @test_type_attribute
        else
          render json: { errors: @test_type_attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/test_type_attributes/:id (soft delete/void)
      def destroy
        @test_type_attribute.voided = 1
        @test_type_attribute.voided_by = User.current&.id
        @test_type_attribute.voided_date = Time.current
        @test_type_attribute.voided_reason = params[:reason] || 'Deleted by user'

        if @test_type_attribute.save
          render json: { message: 'Test type attribute mapping deleted successfully' }
        else
          render json: { errors: @test_type_attribute.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/test_types/:test_type_id/attributes/for_order
      # Returns attributes formatted for display during order creation
      def for_order
        @test_type = TestType.find(params[:test_type_id])
        @attributes = TestTypeAttribute.root_attributes_for_test_type(@test_type.id)

        formatted_attributes = @attributes.map do |tta|
          {
            id: tta.id,
            attribute_id: tta.attribute_id,
            name: tta.attribute.name,
            label: tta.attribute.label,
            description: tta.attribute.description,
            field_type: tta.attribute.field_type,
            options: tta.effective_options,
            is_required: tta.is_required,
            sort_order: tta.sort_order,
            child_attributes: tta.child_attributes_for_test_type
          }
        end

        render json: formatted_attributes
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Test type not found' }, status: :not_found
      end

      private

      def set_test_type
        @test_type = TestType.find(params[:test_type_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Test type not found' }, status: :not_found
      end

      def set_test_type_attribute
        @test_type_attribute = TestTypeAttribute.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Test type attribute mapping not found' }, status: :not_found
      end

      def test_type_attribute_params
        params.require(:test_type_attribute).permit(
          :attribute_id,
          :is_required,
          :sort_order,
          :parent_attribute_id,
          :parent_attribute_value,
          :active,
          test_type_specific_options: []
        )
      end
    end
  end
end
