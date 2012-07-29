require 'log4r'

class AssignmentSignupsController < ApplicationController

  # set up logger
  @@AssignmentLogger = Log4r::Logger['assignments']
  if @@AssignmentLogger.nil?
    #if logger not in config, create new to avoid startup errors.
    @@AssignmentLogger = Log4r::Logger.new 'assignments'
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @assignment_signups = SignupSheet.find(:all)
  end

  def listuser
    @user_id = session[:user].id  
    if (session[:user].role_id == 1)
      @signups= SignupSheet.find_by_sql("select * from signup_sheets where assignment_id in (select assignment_id from participants where user_id = "+session[:user].id.to_s+")")
    else
      @signups= SignupSheet.find_by_sql("select * from signup_sheets")
    end   
  end

  def show
    @assignment_signup = AssignmentSignup.find(params[:id])
  end
  
  def new
    @@AssignmentLogger.debug("Entering #{self.class.name}::#{__method__}")
    @assignment_signup = AssignmentSignup.new
    @signup_sheets = SignupSheet.find(:all)
    @assignments = Assignment.find_by_sql("select * from assignments where id not in (select assignment_id from assignment_signups where signup_id = "+@params[:id].to_s+")")
    @@AssignmentLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def create
    @@AssignmentLogger.debug("Entering #{self.class.name}::#{__method__}")
    @assignment_signup = AssignmentSignup.new(params[:assignment_signup])
    @assignment_signup.assignment_id = params[:assignment_id]
    @assignment_signup.signup_id = params[:signup_id]      
      
    if @assignment_signup.save
      @assignments = Assignment.find_by_id(params[:assignment_id])
      @@AssignmentLogger.info("Assignment signup was created for #{@assignments.name}.")
      flash[:notice] = 'Assignment Signup was successfully created for assignment '+@assignments.name                   
      redirect_to :controller => 'signup_sheets', :action => 'list'
    else
      @signup_sheets = SignupSheet.find(:all)
      @assignments = Assignment.find(:all)
      render :action => 'new'
    end
    @@AssignmentLogger.debug("Entering #{self.class.name}::#{__method__}")
  end

  def edit
    @@AssignmentLogger.debug("Entering #{self.class.name}::#{__method__}")
    @assignments = Assignment.find(:all)
    @assignment_signup = AssignmentSignup.find(params[:id])
    @@AssignmentLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def update
    @@AssignmentLogger.debug("Entering #{self.class.name}::#{__method__}")
    @assignment_signup = AssignmentSignup.find(params[:id])
    @assignment_signup.assignment_id = params[:assignment_id]
    if @assignment_signup.update_attributes(params[:assignment_signup])
      @@AssignmentLogger.info("Assignmment signup #{@assignment_signup.id} updated.")
      flash[:notice] = 'AssignmentSignup was successfully updated.'
      redirect_to :action => 'show', :id => @assignment_signup
    else
      @assignments = Assignment.find(:all)
      render :action => 'edit'
    end
    @@AssignmentLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end

  def destroy
    AssignmentSignup.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
