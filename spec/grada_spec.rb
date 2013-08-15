require 'spec_helper'

describe Grada do
  context "Data validation" do 
    let(:valid_y)             { [0.001,0.2,3,0.002] }
    let(:valid_x)             { [1, 2, 3, 4] }
    let(:empty_x)             { [] }
    let(:unvalid_x)           { ['a','b','c','d'] }
    let(:valid_matrix)        { [[0, 1000, 0.01],[1000, 0, 0.1],[0.01, 0.1, 0]] }
    let(:unvalid_matrix)      { [[0, 1000, 0.01],[],[0.01, 0.1, 0]] }
    let(:valid_population)    { [1,2,3,2,2,3,1,1,2,1,4] }
    let(:unvalid_population)  { [1,2,3,2,2,3,1,1,2,'1',4] }

    it "should not create a grada object without a list" do
      expect{ Grada::Graph.new({}) }.to raise_error(Grada::Graph::NotValidArrayError)
      expect{ Grada::Graph.new(valid_x, {}) }.to raise_error(Grada::Graph::NotValidArrayError)
    end
    
    it "should not create a grada object with a list with strings" do
      expect{ Grada::Graph.new(unvalid_population) }.to raise_error(Grada::Graph::NotValidDataError)
    end
    
    it "should not create a grada object with two lists of different size" do
      expect{ Grada::Graph.new(unvalid_population, []) }.to raise_error(Grada::Graph::NotValidDataError)
    end
    
    it "should not create a grada object with a list with an unvalid list" do
      expect{ Grada::Graph.new(unvalid_x, valid_y) }.to raise_error(Grada::Graph::NotValidDataError)
    end
    
    it "should not plot a heatmap with an unvalid matrix" do
      grada = Grada::Graph.new(unvalid_matrix)
      expect{ grada.display({graph_type: :heatmap}) }.to raise_error(Grada::Graph::NoPlotDataError)
    end
    
    it "should not plot a histogram with a matrix" do
      grada = Grada::Graph.new(valid_matrix)
      expect{ grada.display({graph_type: :histogram}) }.to raise_error(Grada::Graph::NotValidDataError)
    end
    
    it "should not plot a histogram with an empty list" do
      grada = Grada::Graph.new(empty_x)
      grada.display({graph_type: :histogram}).should be_nil
    end
    
    it "should not plot a default graph with no value in axis Y" do
      grada = Grada::Graph.new(valid_x)
      expect{ grada.display }.to raise_error(Grada::Graph::NoPlotDataError)
    end
  end
end
