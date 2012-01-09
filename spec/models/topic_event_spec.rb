require File.dirname(__FILE__) + '/../spec_helper'

describe TopicEvent do
  let(:topic) { Factory(:topic) }
  let(:user) { Factory(:user) }

  describe '.upcoming' do
    let!(:upcoming_events) {
      5.times.map { Factory(:upcoming_event, :topic => topic, :user => user) }
    }

    context 'when upcoming events are with in next 7 days' do
      it 'should have 5 upcoming events' do
        TopicEvent.upcoming.length.should == 5
      end
    end
  end

  describe '.far_future' do
    context 'when there is no near future events show all of the
             future events sorting by their start date' do
      let!(:upcoming_events) {
        5.times.map { Factory(:upcoming_event, :topic => topic, :user => user) }
      }
      let!(:far_future_events) {
        5.times.map { Factory(:upcoming_event,
                              :start_at => Time.now + 14.days,
                              :end_at   => Time.now + 17.days,
                              :topic    => topic,
                              :user     => user) }
      }

      it 'should count all events' do
        TopicEvent.count.should == 10
      end

      it 'should display events after next 7 days' do
        TopicEvent.far_future.length.should == 5
      end
    end
  end

  describe '.exciting_events' do
    context 'when 0 upcoming events' do
      let!(:far_future_events) {
        5.times.map { Factory(:upcoming_event,
                              :start_at => Time.now + 14.days,
                              :end_at   => Time.now + 17.days,
                              :topic    => topic,
                              :user     => user) }
      }
      let!(:past_events) {
        5.times.map { Factory(:recent_event,
                              :topic    => topic,
                              :user     => user) }
      }

      let!(:events) { TopicEvent.exciting_events(topic) }
      subject { events[:upcoming] }

      its(:length) { should == 5 }
      it 'should include from far future events' do
        ids = far_future_events.map(&:id)
        subject.each do |e|
          ids.include?(e.id).should be_true
        end
      end
    end

    context 'when 2 upcoming events' do
      let!(:far_future) {
        5.times.map { Factory(:upcoming_event,
                              :start_at => Time.now + 14.days,
                              :end_at   => Time.now + 17.days,
                              :topic    => topic,
                              :user     => user) }
      }
      let!(:upcoming) {
        2.times.map { Factory(:upcoming_event,
                              :topic    => topic,
                              :user     => user) }
      }

      let!(:events) { TopicEvent.exciting_events(topic) }
      subject { events[:upcoming] }

      its(:length) { should == 5 }
      it 'should include from far future events' do
        ids = upcoming.map(&:id) + far_future[0..2].map(&:id)
        subject.each do |e|
          ids.include?(e.id).should be_true
        end
      end
    end

    context 'when 2 upcoming events and 1 far future event' do
      let!(:far_future) {
        1.times.map { Factory(:upcoming_event,
                              :start_at => Time.now + 14.days,
                              :end_at   => Time.now + 17.days,
                              :topic    => topic,
                              :user     => user) }
      }
      let!(:upcoming) {
        2.times.map { Factory(:upcoming_event,
                              :topic    => topic,
                              :user     => user) }
      }

      let!(:events) { TopicEvent.exciting_events(topic) }
      subject { events[:upcoming] }

      its(:length) { should == 3 }
      it 'should include from far future events' do
        ids = upcoming.map(&:id) + [far_future.first.id]
        subject.each do |e|
          ids.include?(e.id).should be_true
        end
      end
    end
  end
end