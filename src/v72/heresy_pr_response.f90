program heresy_pr_response
    use iso_fortran_env, only: error_unit
    implicit none

    character(len=1024) :: specimen
    character(len=2048) :: line, value
    character(len=256) :: key
    character(len=128) :: source_kind, source_date, packages
    character(len=32) :: web_text, raw_text
    integer :: unit, ios, tab_at
    integer :: source_kind_count, source_date_count
    integer :: web_count, raw_count, packages_count
    integer :: web_rate, raw_rate
    logical :: malformed, percentage_too_long

    source_kind = ''
    source_date = ''
    packages = ''
    web_text = ''
    raw_text = ''
    source_kind_count = 0
    source_date_count = 0
    web_count = 0
    raw_count = 0
    packages_count = 0
    malformed = .false.
    percentage_too_long = .false.

    call get_command_argument(1, specimen)
    if (len_trim(specimen) == 0) then
        write(error_unit, '(A)') 'PR_RESPONSE_SPECIMEN_REQUIRED'
        stop 64
    end if

    open(newunit=unit, file=trim(specimen), status='old', action='read', iostat=ios)
    if (ios /= 0) then
        write(error_unit, '(A)') 'PR_RESPONSE_SPECIMEN_MISSING'
        stop 66
    end if

    do
        read(unit, '(A)', iostat=ios) line
        if (ios < 0) exit
        if (ios > 0) then
            write(error_unit, '(A)') 'PR_RESPONSE_SPECIMEN_READ_ERROR'
            close(unit)
            stop 65
        end if

        tab_at = index(line, achar(9))
        if (tab_at <= 1) cycle
        key = trim(line(:tab_at - 1))
        value = line(tab_at + 1:)

        if (index(value, achar(9)) /= 0) then
            select case (trim(key))
            case ('SOURCE_KIND', 'SOURCE_DATE', 'WEB_API_ERROR_RATE_PERCENT', &
                  'RAW_DOWNLOAD_ERROR_RATE_PERCENT', 'PACKAGES_STATUS')
                malformed = .true.
            end select
        end if

        select case (trim(key))
        case ('SOURCE_KIND')
            source_kind_count = source_kind_count + 1
            if (len_trim(value) > len(source_kind)) then
                malformed = .true.
            else
                source_kind = trim(value)
            end if
        case ('SOURCE_DATE')
            source_date_count = source_date_count + 1
            if (len_trim(value) > len(source_date)) then
                malformed = .true.
            else
                source_date = trim(value)
            end if
        case ('WEB_API_ERROR_RATE_PERCENT')
            web_count = web_count + 1
            if (len_trim(value) > len(web_text)) then
                percentage_too_long = .true.
            else
                web_text = trim(value)
            end if
        case ('RAW_DOWNLOAD_ERROR_RATE_PERCENT')
            raw_count = raw_count + 1
            if (len_trim(value) > len(raw_text)) then
                percentage_too_long = .true.
            else
                raw_text = trim(value)
            end if
        case ('PACKAGES_STATUS')
            packages_count = packages_count + 1
            if (len_trim(value) > len(packages)) then
                malformed = .true.
            else
                packages = trim(value)
            end if
        end select
    end do
    close(unit)

    if (malformed .or. source_kind_count /= 1 .or. source_date_count /= 1 .or. &
        web_count /= 1 .or. raw_count /= 1 .or. packages_count /= 1) then
        write(error_unit, '(A)') 'PR_RESPONSE_SPECIMEN_AMBIGUOUS'
        stop 65
    end if

    if (percentage_too_long) then
        write(error_unit, '(A)') 'PR_RESPONSE_PERCENT_INVALID'
        stop 65
    end if

    if (len_trim(source_kind) == 0 .or. len_trim(source_date) == 0 .or. &
        len_trim(packages) == 0) then
        write(error_unit, '(A)') 'PR_RESPONSE_SPECIMEN_METADATA_EMPTY'
        stop 65
    end if

    if (.not. digits_only(web_text) .or. .not. digits_only(raw_text)) then
        write(error_unit, '(A)') 'PR_RESPONSE_PERCENT_INVALID'
        stop 65
    end if

    read(web_text, *, iostat=ios) web_rate
    if (ios /= 0) then
        write(error_unit, '(A)') 'PR_RESPONSE_PERCENT_INVALID'
        stop 65
    end if
    read(raw_text, *, iostat=ios) raw_rate
    if (ios /= 0) then
        write(error_unit, '(A)') 'PR_RESPONSE_PERCENT_INVALID'
        stop 65
    end if

    if (web_rate < 0 .or. web_rate > 100 .or. raw_rate < 0 .or. raw_rate > 100) then
        write(error_unit, '(A)') 'PR_RESPONSE_PERCENT_OUT_OF_RANGE'
        stop 65
    end if

    call print_header(source_kind, source_date, web_rate, raw_rate, packages)
    call print_interview(web_rate, raw_rate, packages)

contains

    logical function digits_only(text)
        character(len=*), intent(in) :: text
        integer :: i, n

        n = len_trim(text)
        digits_only = n > 0
        if (.not. digits_only) return
        do i = 1, n
            if (text(i:i) < '0' .or. text(i:i) > '9') then
                digits_only = .false.
                return
            end if
        end do
    end function digits_only

    subroutine print_header(kind, date_text, web, raw, package_state)
        character(len=*), intent(in) :: kind, date_text, package_state
        integer, intent(in) :: web, raw

        write(*, '(A)') 'HERESY/360 v7.2.0 — PUBLIC RELATIONS RESPONSE SIMULATOR'
        write(*, '(A)') 'FORM: ORIGINAL AUSTRALIAN DEADPAN PUBLIC-AFFAIRS TWO-HANDER'
        write(*, '(A)') 'ATTRIBUTION: FICTIONAL SATIRE; NOT A GITHUB STATEMENT OR REAL SPOKESPERSON'
        write(*, '(A)') 'INSPIRATION: CLASSIC TWO-PERSON BROADCAST INTERVIEW SATIRE; DIALOGUE IS ORIGINAL'
        write(*, '(A)') 'SOURCE_KIND=' // trim(kind)
        write(*, '(A)') 'SOURCE_DATE=' // trim(date_text)
        write(*, '(A,I0)') 'OBSERVED_WEB_API_ERROR_RATE_PERCENT=', web
        write(*, '(A,I0)') 'OBSERVED_RAW_DOWNLOAD_ERROR_RATE_PERCENT=', raw
        write(*, '(A)') 'OBSERVED_PACKAGES_STATUS=' // trim(package_state)
        write(*, '(A)') 'ROOT_CAUSE_INFERRED=0'
        write(*, '(A)') 'ACTUAL_GITHUB_RESPONSE_CLAIMED=0'
        write(*, '(A)') ''
    end subroutine print_header

    subroutine print_interview(web, raw, package_state)
        integer, intent(in) :: web, raw
        character(len=*), intent(in) :: package_state
        character(len=32) :: web_s, raw_s

        write(web_s, '(I0)') web
        write(raw_s, '(I0)') raw

        write(*, '(A)') 'INTERVIEWER: Thanks for joining us.'
        write(*, '(A)') 'PUBLIC_RELATIONS: Delighted. Reliability is very important to us.'
        write(*, '(A)') 'INTERVIEWER: The status snapshot reported about ' // &
                        trim(web_s) // '% errors for web and API traffic.'
        write(*, '(A)') 'PUBLIC_RELATIONS: It reported approximately that figure, yes.'
        write(*, '(A)') 'INTERVIEWER: And raw and archive downloads were about ' // &
                        trim(raw_s) // '% errors?'
        write(*, '(A)') 'PUBLIC_RELATIONS: Approximately.'

        if (raw == 0) then
            write(*, '(A)') 'INTERVIEWER: The observed raw/archive error rate was zero?'
            write(*, '(A)') 'PUBLIC_RELATIONS: For that field in this specimen, yes.'
        else if (raw == 50) then
            write(*, '(A)') 'INTERVIEWER: So a download was, statistically, a coin toss?'
            write(*, '(A)') 'PUBLIC_RELATIONS: That is a very binary description of a cloud service.'
        else if (raw > 50) then
            write(*, '(A)') 'INTERVIEWER: So failure was more likely than success?'
            write(*, '(A)') 'PUBLIC_RELATIONS: We prefer not to rank the outcomes emotionally.'
        else
            write(*, '(A)') 'INTERVIEWER: So the download path had a positive observed error rate?'
            write(*, '(A)') 'PUBLIC_RELATIONS: That is what the supplied percentage says.'
        end if

        write(*, '(A)') 'INTERVIEWER: Was the platform healthy?'
        write(*, '(A)') 'PUBLIC_RELATIONS: The supplied fields do not establish platform-wide health.'
        write(*, '(A)') 'INTERVIEWER: That was almost a direct answer.'
        write(*, '(A)') 'PUBLIC_RELATIONS: We are reviewing the process that allowed it.'

        if (trim(package_state) == 'NORMAL') then
            write(*, '(A)') 'INTERVIEWER: Packages was normal.'
            write(*, '(A)') 'PUBLIC_RELATIONS: Correct.'
            write(*, '(A)') 'INTERVIEWER: One employee reported for work.'
            write(*, '(A)') 'PUBLIC_RELATIONS: We regard that as a strong cross-functional signal.'
        else
            write(*, '(A)') 'INTERVIEWER: Packages was not recorded as normal.'
            write(*, '(A)') 'PUBLIC_RELATIONS: Then we will not make the Packages-normal joke.'
            write(*, '(A)') 'INTERVIEWER: Factual restraint?'
            write(*, '(A)') 'PUBLIC_RELATIONS: Legal has had an extraordinary quarter.'
        end if

        write(*, '(A)') 'INTERVIEWER: What caused the incident?'
        write(*, '(A)') 'PUBLIC_RELATIONS: The supplied snapshot does not establish root cause.'
        write(*, '(A)') 'INTERVIEWER: Finally, a precise answer.'
        write(*, '(A)') 'PUBLIC_RELATIONS: We can workshop it.'
        write(*, '(A)') 'INTERVIEWER: Is this GitHub''s actual response?'
        write(*, '(A)') 'PUBLIC_RELATIONS: No. This exchange is fictional satire generated by Fortran.'
        write(*, '(A)') 'INTERVIEWER: That is the clearest statement you have made.'
        write(*, '(A)') 'PUBLIC_RELATIONS: We will take that under advisement.'
        write(*, '(A)') ''
        write(*, '(A)') 'HERESY-E-PR: STATEMENT COMPLETE; NOTHING FURTHER HAS BEEN CLARIFIED.'
    end subroutine print_interview

end program heresy_pr_response
