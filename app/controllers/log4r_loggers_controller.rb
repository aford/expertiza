require 'log4r'
# include Log4r
class Log4rLoggersController < ApplicationController
  # GET /log4r_loggers
  # GET /log4r_loggers.xml
  def index
    log =  Log4r::Logger['teammate_review']
    log.info("MMDEBUG - Test message from debugr")
    @log4r_loggers = Log4rLogger.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @log4r_loggers }
    end
  end

  # GET /log4r_loggers/1
  # GET /log4r_loggers/1.xml
  def show
    @log4r_logger = Log4rLogger.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @log4r_logger }
    end
  end

  # GET /log4r_loggers/new
  # GET /log4r_loggers/new.xml
  def new
    @log4r_logger = Log4rLogger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @log4r_logger }
    end
  end

  # GET /log4r_loggers/1/edit
  def edit
    @log4r_logger = Log4rLogger.find(params[:id])
  end

  # POST /log4r_loggers
  # POST /log4r_loggers.xml
  def create
    @log4r_logger = Log4rLogger.new(params[:log4r_logger])

    respond_to do |format|
      if @log4r_logger.save
        format.html { redirect_to(@log4r_logger, :notice => 'Log4rLogger was successfully created.') }
        format.xml  { render :xml => @log4r_logger, :status => :created, :location => @log4r_logger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @log4r_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /log4r_loggers/1
  # PUT /log4r_loggers/1.xml
  def update
    @log4r_logger = Log4rLogger.find(params[:id])

    respond_to do |format|
      if @log4r_logger.update_attributes(params[:log4r_logger])
        format.html { redirect_to(@log4r_logger, :notice => 'Log4rLogger was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @log4r_logger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /log4r_loggers/1
  # DELETE /log4r_loggers/1.xml
  def destroy
    @log4r_logger = Log4rLogger.find(params[:id])
    @log4r_logger.destroy

    respond_to do |format|
      format.html { redirect_to(log4r_loggers_url) }
      format.xml  { head :ok }
    end
  end
end
