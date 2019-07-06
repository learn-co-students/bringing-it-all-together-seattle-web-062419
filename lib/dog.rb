class Dog

    attr_accessor :id, :name, :breed

    def initialize(id:nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.create(hash)
        new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
        new_dog.save
    end

    def self.find_or_create_by(hash)
        
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ? AND breed = ?
        SQL
        
        check = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten
        
        if check.size > 0
            Dog.new_from_db(check)
        else
            sql2 = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL
            
            DB[:conn].execute(sql2, hash[:name], hash[:breed])

            sql3 = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ? AND breed = ?;
            SQL
            
            result = DB[:conn].execute(sql3, hash[:name], hash[:breed]).flatten
            Dog.new(id: result[0], name: result[1], breed: result[2])
        end
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?;
        SQL
        
        result = DB[:conn].execute(sql, id).flatten
        Dog.new_from_db(result)
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?
        WHERE id = ?;
        SQL

        DB[:conn].execute(sql, self.name, self.id)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def self.new_from_db(array)
        Dog.new(id: array[0], name: array[1], breed: array[2])
    end

    def save
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL
        
        check = DB[:conn].execute(sql, self.id)
        
        if check.size > 0
            sql2 = <<-SQL
            UPDATE dogs
            SET name = ?
            WHERE id = ?;
            SQL

            DB[:conn].execute(sql2, self.name, self.id)
        else
            sql3 = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?);
            SQL
            
            DB[:conn].execute(sql3, self.name, self.breed)

            sql4 = <<-SQL
            SELECT *
            FROM dogs
            ORDER BY id DESC;
            SQL

            result = DB[:conn].execute(sql4).flatten
            Dog.new_from_db(result)
        end
       
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?;
        SQL
        
        row = DB[:conn].execute(sql, name).flatten
        Dog.new_from_db(row)
    end


end