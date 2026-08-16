program heresy_runtime
  implicit none

  character(len=32)  :: arg_rule
  character(len=32)  :: arg_evidence
  character(len=32)  :: arg_remediation
  character(len=96)  :: arg_remediation_ref
  character(len=64)  :: decision
  character(len=32)  :: code
  character(len=96)  :: remediation
  logical            :: rule_specific
  logical            :: evidence_present
  logical            :: remediation_available
  integer            :: score

  call get_command_argument(1, arg_rule)
  call get_command_argument(2, arg_evidence)
  call get_command_argument(3, arg_remediation)
  call get_command_argument(4, arg_remediation_ref)

  rule_specific    = trim(arg_rule) == '1'
  evidence_present = trim(arg_evidence) == '1'
  remediation_available = trim(arg_remediation) == '1' .and. &
       len_trim(arg_remediation_ref) > 0 .and. &
       trim(arg_remediation_ref) /= 'NONE' .and. &
       trim(arg_remediation_ref) /= 'MISSING' .and. &
       trim(arg_remediation_ref) /= 'UNSPECIFIED'

  score = 0
  if (rule_specific) score = score + 40
  if (evidence_present) score = score + 40
  if (remediation_available) score = score + 20

  if (.not. rule_specific) then
     decision = 'REFUSE_ENFORCEMENT'
     code = 'DP-001'
     remediation = 'NAME_THE_RULE_BEFORE_PUNISHING_THE_USER'
  else if (.not. evidence_present) then
     decision = 'REFUSE_ENFORCEMENT'
     code = 'DP-002'
     remediation = 'PROVIDE_AN_EVIDENCE_REFERENCE'
  else if (remediation_available) then
     decision = 'LOCKED_PENDING_REMEDIATION'
     code = 'DP-200'
     remediation = trim(arg_remediation_ref)
  else
     decision = 'HUMAN_REVIEW_REQUIRED'
     code = 'DP-300'
     remediation = 'ESCALATE_WITH_RULE_AND_EVIDENCE_ATTACHED'
  end if

  write(*,'(A)') 'RUNTIME=HERESY/360-FORTRAN'
  write(*,'(A,A)') 'DECISION=', trim(decision)
  write(*,'(A,A)') 'POLICY_CODE=', trim(code)
  write(*,'(A,I0)') 'TRANSPARENCY_SCORE=', score
  write(*,'(A,A)') 'REMEDIATION=', trim(remediation)
end program heresy_runtime
