class VisitType < RetirableRecord
    validates :name, presence: true, uniqueness: true
end
