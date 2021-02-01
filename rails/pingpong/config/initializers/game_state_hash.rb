require 'singleton'

class GameStateHash < Hash
    include Singleton

    def initialize
        super([])
    end

    def add_kv(key, value)
        self[key] = value
    end

    def return_value(key)
        return self[key]
    end

    def delete_key(key)
        self[key].delete if self[key]
    end

end