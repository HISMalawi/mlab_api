class Client < VoidableRecord
  belongs_to :person

  def as_json(options = {})
    super(options.merge(include: %i[person]))
  end
end
