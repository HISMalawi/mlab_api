class TtJob
  include Sidekiq::Job

  def perform
    by_sex = Report.find_by_sql("
      SELECT
        COUNT(DISTINCT c.id) AS count, p.sex
      FROM
        clients c
      INNER JOIN
        people p ON p.id = c.person_id AND c.voided = 0
      AND p.voided = 0
        GROUP BY p.sex
    ")
    result = {}
    count = { 'F' => 0, 'M' => 0 }
    by_sex.each do |sex|
      count[sex['sex']] = sex['count']
    end
    c_count = Report.find_by_sql('SELECT COUNT(DISTINCT c.id) AS count FROM clients c').first
    result['clients'] = c_count.count
    result['by_sex'] = count
    result
  end
end