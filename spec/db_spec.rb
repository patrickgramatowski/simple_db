# frozen_string_literal: true

require "database"

describe Db do
  before do
    @db = Db.new
    @db.set("SET A 10")
  end

  describe ".get" do
    context "given input 'GET A 10'" do
      it "returns value of 10" do
        expect(@db.get("GET A 10")).to eql(%w[A 10])
      end
    end
  end

  describe ".count" do
    context "given input 'COUNT 10'" do
      it "returns value of 1" do
        expect(@db.count("COUNT 10")).to eql(nil)
      end
    end
  end
end
