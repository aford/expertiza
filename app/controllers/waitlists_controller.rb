require 'log4r'

class WaitlistsController < ApplicationController
  # set up logger
  @@TopicLogger = Log4r::Logger['topics']
  if @@TopicLogger.nil?
    #if logger not in config, create new to avoid startup errors.
    @@TopicLogger = Log4r::Logger.new 'topics'
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @waitlists = Waitlist.paginate(:page => params[:page], :per_page => 10)
  end

  def show
    @waitlist = Waitlist.find(params[:id])
  end

  def new
    @@TopicLogger.debug("Entering #{self.class.name}::#{__method__}")
    @waitlist = Waitlist.new
    @@TopicLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def create
    @@TopicLogger.debug("Entering #{self.class.name}::#{__method__}")
    @waitlist = Waitlist.new(params[:waitlist])
    @user = session[:user]
    if @waitlist.save
      @@TopicLogger.info("Waitlist #{@waitlist.id} was created by #{@user.name}.")
      flash[:notice] = 'Waitlist was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
    @@TopicLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def edit
    @@TopicLogger.debug("Entering #{self.class.name}::#{__method__}")
    @waitlist = Waitlist.find(params[:id])
    @@TopicLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def update
    @@TopicLogger.debug("Entering #{self.class.name}::#{__method__}")
    @waitlist = Waitlist.find(params[:id])
    if @waitlist.update_attributes(params[:waitlist])
      @@TopicLogger.debug("Waitlist #{@waitlist.id} updated.")
      flash[:notice] = 'Waitlist was successfully updated.'
      redirect_to :action => 'show', :id => @waitlist
    else
      render :action => 'edit'
    end
    @@TopicLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def destroy
    @@TopicLogger.debug("Entering #{self.class.name}::#{__method__}")
    Waitlist.find(params[:id]).destroy
    @@TopicLogger.debug("Waitlist #{params[:id]} destroyed.")
    redirect_to :action => 'list'
    @@TopicLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
end
