# encoding: UTF-8

require 'spec_helper'

describe CloudModel::AcceptSizeStrings do
  class TestBackupToolsModel
    include Mongoid::Document
    include CloudModel::BackupTools
  end
  
  subject { TestBackupToolsModel.new }
  
  it "should keep last 3 backups" do
    keep_backups = [
      (Time.now-1.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-2.years).strftime("%Y%m%d%H%M%S"),
      (Time.now-6.years).strftime("%Y%m%d%H%M%S"),
    ]
    disposable_backups = [
      (Time.now-8.years).strftime("%Y%m%d%H%M%S"),    
      (Time.now-13.years).strftime("%Y%m%d%H%M%S"), 
      (Time.now-15.years).strftime("%Y%m%d%H%M%S"),    
    ]
    backups = keep_backups + disposable_backups
    
    subject.stub(:list_backups).and_return backups
    expect(subject.list_disposable_backups).to match_array disposable_backups
  end
  
  it "should keep all backups of the last 3 days" do
    keep_backups = [
      (Time.now-1.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-36.hours).strftime("%Y%m%d%H%M%S"),
      (Time.now-2.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-60.hours).strftime("%Y%m%d%H%M%S"),
    ]
    disposable_backups = [
      (Time.now-3.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-8.years).strftime("%Y%m%d%H%M%S"),    
      (Time.now-13.years).strftime("%Y%m%d%H%M%S"), 
      (Time.now-15.years).strftime("%Y%m%d%H%M%S"),    
    ]
    backups = keep_backups + disposable_backups
    
    subject.stub(:list_backups).and_return backups
    expect(subject.list_disposable_backups).to match_array disposable_backups
  end
  
  it "should keep one backup for the last 7 days" do
    keep_backups = [
      (Time.now-1.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-2.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-3.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-4.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-5.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-6.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-7.days).strftime("%Y%m%d%H%M%S"),
      (Time.now-14.days).strftime("%Y%m%d%H%M%S"),
    ]
    disposable_backups = [
      (Time.now-45.hours).strftime("%Y%m%d%H%M%S"),    
      (Time.now-8.days).strftime("%Y%m%d%H%M%S"),    
      (Time.now-13.days).strftime("%Y%m%d%H%M%S"), 
      (Time.now-15.days).strftime("%Y%m%d%H%M%S"),    
    ]
    backups = keep_backups + disposable_backups
    
    subject.stub(:list_backups).and_return backups
    expect(subject.list_disposable_backups).to match_array disposable_backups
  end
end