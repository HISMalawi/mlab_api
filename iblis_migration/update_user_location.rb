# frozen_string_literal: true

user_lab_locations = UserLabLocationMapping.all.pluck(:user_id)
users = User.where.not(id: user_lab_locations).pluck('id')

def departments_contains?(names, substring)
  departments = names.select do |name|
    name.downcase.include?(substring)
  end
  !departments.empty?
end

def main_lab?(names)
  depart = names.reject do |name|
    name.downcase.include?('paed') || name.downcase.include?('cancer')
  end
  !depart.empty?
end

users.each do |user_id|
  departments = Department.joins(:user_department_mappings).where("user_department_mappings.user_id = #{user_id}")
                          .pluck('departments.name')
  departments_containing_paeds = departments_contains?(departments, 'paed')
  departments_containing_cancer = departments_contains?(departments, 'cancer')
  departments_containing_main = main_lab?(departments)
  lab_locations = []
  if departments_containing_paeds
    location = LabLocation.find_by_name('Paediatric Lab')&.id
    lab_locations << location unless location.nil?
  end
  if departments_containing_cancer
    location = LabLocation.find_by_name('Cancer Lab')&.id
    lab_locations << location unless location.nil?
  end
  if departments_containing_main
    location = LabLocation.find_by_name('Main Lab')&.id
    lab_locations << location unless location.nil?
  end
  puts "Updating lab locations for user #{user_id}"
  UserManagement::UserService.update_lab_locations(user_id, lab_locations)
end

# void departments with cancer or paeds
departments = Department.where("name LIKE '%paediatric%' OR name LIKE '%cancer%'")
departments.each do |department|
  department.void('No longer needed')
end
