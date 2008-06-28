require File.dirname(__FILE__) + '/../spec_helper'

describe Episode do
  it "should find published" do
    a = Factory.create(:episode, :published_at => 2.weeks.ago)
    b = Factory.create(:episode, :published_at => 2.weeks.from_now)
    Episode.published.should include(a)
    Episode.published.should_not include(b)
  end
  
  it "should assign tags to episodes" do
    episode = Factory.create(:episode, :tag_names => 'foo bar')
    episode.tags.map(&:name) == %w[foo bar]
    episode.tag_names.should == 'foo bar'
  end
  
  it "should require publication date" do
    episode = Episode.new
    episode.should have(1).error_on(:published_at)
  end
  
  it "should group episodes by month" do
    Episode.delete_all
    a = Factory.create(:episode, :published_at => '2008-01-01')
    b = Factory.create(:episode, :published_at => '2008-01-05')
    c = Factory.create(:episode, :published_at => '2008-02-05')
    months = Episode.by_month
    months[Time.parse('2008-01-01')].should == [a, b]
    months[Time.parse('2008-02-01')].should == [c]
  end
end