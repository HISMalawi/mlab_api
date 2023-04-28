class Facility < RetirableRecord
    validates :name, uniqueness: true, presence: true
end
