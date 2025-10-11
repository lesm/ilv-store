# frozen_string_literal: true

# Mock Typesense client for test environment
class TypesenseMockClient
  def collections
    @collections ||= CollectionsMock.new
  end

  class CollectionsMock
    def [](name)
      @collection ||= CollectionMock.new
    end

    def create(schema)
      CollectionMock.new
    end
  end

  class CollectionMock
    def documents
      @documents ||= DocumentsMock.new
    end

    def create
      true
    end
  end

  class DocumentsMock
    def upsert(_document)
      { 'id' => SecureRandom.uuid }
    end

    def search(_params)
      { 'hits' => [], 'found' => 0 }
    end

    def [](id)
      DocumentMock.new(id)
    end
  end

  class DocumentMock
    def initialize(id)
      @id = id
    end

    def delete
      true
    end
  end
end
