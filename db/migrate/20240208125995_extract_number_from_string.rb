# frozen_string_literal: true

# Extract the number from the string migration
class ExtractNumberFromString < ActiveRecord::Migration[7.0]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE FUNCTION ExtractNumberFromString(input_string VARCHAR(255))
          RETURNS VARCHAR(255)
          DETERMINISTIC
          NO SQL
          BEGIN
            RETURN (
              SUBSTRING(
                REGEXP_SUBSTR(input_string, '[0-9]+(?:\\.[0-9]+)?'), 
                1,
                CHAR_LENGTH(REGEXP_SUBSTR(input_string, '[0-9]+(?:\\.[0-9]+)?'))
              )
            );
          END;
        SQL
      end

      dir.down do
        execute 'DROP FUNCTION IF EXISTS ExtractNumberFromString;'
      end
    end
  end
end
