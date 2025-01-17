# frozen_string_literal: true

module Serializers
  # Serializer for test result
  module TestSerializer
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def self.serialize(record)
      {
        id: record['id'],
        order_id: record['order_id'],
        specimen_id: record['specimen_id'],
        specimen_type: record['specimen'],
        test_panel_id: record['test_panel_id'],
        test_panel_name: record['test_panel_name'],
        created_date: record['created_date'],
        request_origin: record['request_origin'],
        requesting_ward: record['requesting_ward'],
        accession_number: record['accession_number'],
        test_type_id: record['test_type_id'],
        test_type_name: record['test_type'],
        tracking_number: record['tracking_number'],
        voided: record['voided'],
        requested_by: record['requested_by'],
        completed_by: completed_by(record['id'], record['t_status_id']),
        client: client_object(record),
        status: record['t_status'],
        rejection_reason: record['rejected_reason'],
        order_status: record['o_status'],
        lab_location: LabLocation.find_by(id: record['lab_location_id'])
      }
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize

    def self.completed_by(test_id, status_id)
      return {} if status_id.nil? || !%w[completed verified].include?(Status.find(status_id)&.name)

      test_status = TestStatus.find_by(test_id:, status_id:)
      user = User.find_by(id: test_status&.creator)
      return {} if user.nil?

      {
        id: user.id,
        username: user.username,
        is_super_admin: super_admin?(user.id),
        status_id: test_status&.status_id
      }
    end

    def self.super_admin?(user_id)
      roles = UserRoleMapping.joins(:role).where(user_id:).pluck('roles.name')
      (roles.map!(&:downcase) & %w[superuser superadmin]).any?
    end

    def self.client_object(record)
      {
        patient_no: record['patient_no'],
        first_name: record['first_name'],
        middle_name: record['middle_name'],
        last_name: record['last_name'],
        sex: record['sex'],
        date_of_birth: record['date_of_birth'],
        birth_date_estimated: record['birth_date_estimated']
      }
    end
  end
end
