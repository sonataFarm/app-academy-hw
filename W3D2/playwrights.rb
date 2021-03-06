class Playwright

  def self.from_data(data)
    playwrights = data.map { |datum| Playwright.new(datum) }
    playwrights.count == 1 ? playwrights.first : playwrights
  end

  def self.all
    data = PlayDBConnection.instance.execute("SELECT * FROM playwrights")
    Playwright.from_data(data)
  end

  def self.find_by_name(name)
    data = PlayDBConnection.instance.execute(<<-SQL, name)
      SELECT * FROM playwrights
      WHERE name = ?
    SQL

    Playwright.from_data(data)
  end

  attr_accessor :name, :birth_year
  def initialize(options)
    @id = options['id']
    @name = options['name']
    @birth_year = options['birth_year']
  end

  def create
    raise "#{self} already in database" if @id
    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year)
      INSERT INTO playwrights (name, birth_year)
      VALUES (?, ?)
    SQL

    @id = PlayDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    PlayDBConnection.instance.execute(<<-SQL, @name, @birth_year, @id)
      UPDATE
        playwrights
      SET
        name = ?, birth_year = ?
      WHERE
        id = ?
    SQL
  end

  def get_plays
    Play.find_by_playwright(@name)
  end
end
