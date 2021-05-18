# frozen_string_literal: true

require_relative "../lib/db_main/database"

RSpec.describe Db do
  describe "#get" do
    before do
      described_class.new.set("SET A 10")
    end
    context "given input 'GET A 10'" do
      let(:expected) { "10" }
      let!(:get) { subject.get("GET A") }
      it "returns value of 10" do
        expect(get).to include(expected)
      end
    end
  end

  describe "#count" do
    before do
      described_class.new.set("SET A 10")
    end
    context "given input 'COUNT 10'" do
      let(:expected) { 1 }
      let(:count) { subject.count("COUNT 10") }
      it "returns value of 1" do
        expect(count).to eql(expected)
      end
    end
  end
end
