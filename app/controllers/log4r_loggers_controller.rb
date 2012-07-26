require 'log4r_aford'
# include Log4r
class Log4rLoggersController < ApplicationController
  # GET /log4r_loggers
  # GET /log4r_loggers.xml
  def index
    @log4r_loggers = Log4rLogger.all

    respond_to do |format|
      if !params[:updatecfg].nil?
        Log4rLoggersHelper::generate_log4r_config
        format.html { redirect_to(log4r_loggers_url, :notice => 'Log4rLogger was successfully updated. Please restart the server for the changes to take effect.') }
      else
        params[:updatecfg] = nil
        format.html # index.html.erb
        format.xml  { render :xml => @log4r_loggers }
      end
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
        Log4rLoggersHelper::generate_log4r_config
        format.html { redirect_to(@log4r_logger, :notice => 'Log4rLogger was successfully created. Please restart the server for the changes to take effect.') }
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
        Log4rLoggersHelper::generate_log4r_config
        format.html { redirect_to(@log4r_logger, :notice => 'Log4rLogger was successfully updated. Please restart the server for the changes to take effect.') }
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
      Log4rLoggersHelper::generate_log4r_config
      format.html { redirect_to(log4r_loggers_url, :notice => 'Log4rLogger was successfully updated. Please restart the server for the changes to take effect.') }
      format.xml  { head :ok }
    end
  end
end
