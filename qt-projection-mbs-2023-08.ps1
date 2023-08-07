
# ----------------------------------------------------------------------
# 2023-08-06 Update from John Comiskey
# Removed CUSIP and GLD.
# ----------------------------------------------------------------------

# $rate = 0.83

# $month = '2022-12-'

# $dates = @(
#     '2022-11-30'
#     '2022-12-07'
#     '2022-12-14'
#     '2022-12-21'
#     '2022-12-28'
#     '2023-01-04'
# )

# $rate = 3.32 / 3.52 # Dec / Nov    0.94

# $month = '2023-01-'

# $dates = @(
#     '2023-01-04'
#     '2023-01-11'
#     '2023-01-18'
#     '2023-01-25'
#     '2023-02-01'
# )

# $rate = 2.75 / 3.32 # Jan / Dec    0.882

# $month = '2023-02-'

# $dates = @(
#     '2023-02-01'
#     '2023-02-08'
#     '2023-02-15'
#     '2023-02-22'
#     '2023-03-01'
# )

# $rate = 0.83     # Not yet known Feb/Jan
# $rate = 0.85     # Not yet known Feb/Jan
# $rate = 0.94     # Not yet known Feb/Jan

# $2023_01 = 2.75
# $2023_02 = 3.25

# $rate = $2023_02 / $2023_01 # 1.18

# $month = '2023-03-'

# $dates = @(
#     '2023-03-01'
#     '2023-03-08'
#     '2023-03-15'
#     '2023-03-22'
#     '2023-03-29'
#     '2023-04-05'
# )

# $rate = 0.83     # Not yet known
# $rate = 1.18     

# $month = '2023-04-'

# $dates = @(
#     '2023-04-05'
#     '2023-04-12'
#     '2023-04-19'
#     '2023-04-26'
#     '2023-05-03'
# )

# $rate = .935

# $month = '2023-05-'

# $dates = @(
#     '2023-05-03'
#     '2023-05-10'
#     '2023-05-17'
#     '2023-05-24'
#     '2023-05-31'
# )

# $rate = 0.83     # Not yet known
# $rate = 1.18     # Not yet known

# $month = '2023-06-'

# $dates = @(
#     '2023-05-31'
#     '2023-06-07'
#     '2023-06-14'
#     '2023-06-21'
#     '2023-06-28'
#     '2023-07-05'
# )
# ----------------------------------------------------------------------
# $rate = 0.83     # Not yet known
# $rate = 1.04     # Not yet known

# $month = '2023-07-'

# $dates = @(
#     '2023-07-05'
#     '2023-07-12'
#     '2023-07-19'
#     '2023-07-26'
#     '2023-08-02'
# )
# ----------------------------------------------------------------------
# $rate = 0.83     # Not yet known
$rate = 1.04     # Not yet known

$month = '2023-08-'

$dates = @(
    '2023-08-02'
    '2023-08-09'
    '2023-08-16'
    '2023-08-23'
    '2023-08-30'
    '2023-09-06'
)
# ----------------------------------------------------------------------

function soma-mbs-get-asof ($date)
{
    $file = 'soma-mbs-get-asof-{0}.json' -f $date

    if (Test-Path $file)
    {
        Write-Host ('Retrieving from file {0}' -f $file)
        Get-Content $file | ConvertFrom-Json
    }
    else
    {
        Write-Host ('Downloading {0}' -f $date)

        $result = Invoke-RestMethod ('https://markets.newyorkfed.org/api/soma/mbs/get/asof/{0}.json' -f $date)

        $result | ConvertTo-Json -Depth 100 | Out-File $file

        $result
    }    
}

function get-sum ($text, $date)
{
    $result = soma-mbs-get-asof $date

    # $result | ft * | Out-String | Write-Host

    # $result.soma.holdings | Where-Object securityDescription -match $text | ft * | Out-String | Write-Host

    # $result.soma.holdings | Where-Object securityDescription -match $text | Format-Table * > ('{0}-{1}-records.txt' -f $date, $text)
        
    ($result.soma.holdings | Where-Object securityDescription -match $text | Measure-Object -Property currentFaceValue -Sum).Sum    
}

function get-change ($text, $a, $b)
{        
    $sum_a = get-sum $text $a         
    $sum_b = get-sum $text $b
       
    $sum_b - $sum_a
}
# ----------------------------------------------------------------------
# April dates for May

# $dates = @(
#     '2023-04-05'
#     '2023-04-12'
#     '2023-04-19'
#     '2023-04-26'
#     '2023-05-03'
# )

# $gnma_i_change_  = (get-change 'GNMA I '  '2023-04-05' '2023-05-03')
# $gld_change_     = (get-change 'FHLMCGLD' '2023-04-05' '2023-05-03')
# $gnma_ii_change_ = (get-change 'GNMA II'  '2023-04-05' '2023-05-03')
# $cusip_change_   = (get-change 'UMBS'     '2023-04-05' '2023-04-19') # 3rd from last Wed
# $umbs_change_    = (get-change 'UMBS'     '2023-04-05' '2023-05-03')
# ----------------------------------------------------------------------
# May dates for June

# $dates = @(
#     '2023-05-03'
#     '2023-05-10'
#     '2023-05-17'
#     '2023-05-24'
#     '2023-05-31'
# )

# $gnma_i_change_  = (get-change 'GNMA I '  '2023-05-03' '2023-05-31')
# $gld_change_     = (get-change 'FHLMCGLD' '2023-05-03' '2023-05-31')
# $gnma_ii_change_ = (get-change 'GNMA II'  '2023-05-03' '2023-05-31')
# $cusip_change_   = (get-change 'UMBS'     '2023-05-03' '2023-05-24') # 3rd from last Wed
# $umbs_change_    = (get-change 'UMBS'     '2023-05-03' '2023-05-31')
# ----------------------------------------------------------------------
# June dates for July

# $dates = @(
#     '2023-05-31'
#     '2023-06-07'
#     '2023-06-14'
#     '2023-06-21'
#     '2023-06-28'
#     '2023-07-05'
# )

# $gnma_i_change_  = (get-change 'GNMA I '  '2023-05-31' '2023-07-05')
# $gnma_ii_change_ = (get-change 'GNMA II'  '2023-05-31' '2023-07-05')
# $umbs_change_    = (get-change 'UMBS'     '2023-05-31' '2023-07-05')
# ----------------------------------------------------------------------
# July dates for Aug

# $dates = @(
#     '2023-07-05'
#     '2023-07-12'
#     '2023-07-19'
#     '2023-07-26'
#     '2023-08-02'
# )

$gnma_i_change_  = (get-change 'GNMA I '  '2023-07-05' '2023-08-02')
$gnma_ii_change_ = (get-change 'GNMA II'  '2023-07-05' '2023-08-02')
$umbs_change_    = (get-change 'UMBS'     '2023-07-05' '2023-08-02')
# ----------------------------------------------------------------------
$total = $umbs_change_ + $gnma_i_change_ + $gnma_ii_change_

function calc-new ($val)
{
    $reg = 5000000000 * $val / $total * -1 # regular payment portion

    $pre = $val - $reg                     # pre-payment portion

    $reg + $rate * $pre
}

$gnma_i_change  = calc-new $gnma_i_change_
$gnma_ii_change = calc-new $gnma_ii_change_
$umbs_change    = calc-new $umbs_change_

function calc-reg ($val)
{
    5000000000 * $val / $total * -1
}

function calc-pre ($val)
{
    $reg = calc-reg $val

    ($val - $reg) * $rate
}

# ----------------------------------------------------------------------

Write-Host ('rate: {0:N3}' -f $rate) -ForegroundColor Yellow
Write-Host

#           UMBS    :   -10,039,438,836.07    -6,610,159,858.45    -3,429,278,977.61   -11,409,544,697.64
Write-Host '                         TOTAL           PREPAYMENT              REGULAR             PREVIOUS'
'GNMA I  : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($gnma_i_change ).ToString('N'), (calc-pre $gnma_i_change_),  (calc-reg $gnma_i_change_),  $gnma_i_change_
'GNMA II : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($gnma_ii_change).ToString('N'), (calc-pre $gnma_ii_change_), (calc-reg $gnma_ii_change_), $gnma_ii_change_
'UMBS    : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($umbs_change   ).ToString('N'), (calc-pre $umbs_change_),    (calc-reg $umbs_change_),    $umbs_change_
'TOTAL   : {0,20}' -f ($umbs_change + $gnma_i_change + $gnma_ii_change).ToString('N')


# function table-row ($name, $val)
# {
#     [PSCustomObject]@{
#         type = $name
#         total = (calc-new $val).ToString('N')
#         pre   = (calc-pre $val).ToString('N')
#         reg   = (calc-reg $val).ToString('N')
#     }
# }

# @(
# table-row 'UMBS'          $umbs_change_
# table-row 'GNMA I + GOLD' ($gnma_i_change_ + $gld_change_)
# table-row 'GNMA II'       $gnma_ii_change_
# ) | Format-Table



Write-Host
# ----------------------------------------------------------------------
$types = @(
    [pscustomobject]@{ date = $month + '15'; type = 'GNMA I' ; value = $gnma_i_change  }
    [pscustomobject]@{ date = $month + '20'; type = 'GNMA II'; value = $gnma_ii_change }
    [pscustomobject]@{ date = $month + '25'; type = 'UMBS'   ; value = $umbs_change    }
)

function loop ($dates)
{
    if ($dates.Count -ge 2) 
    {
        # $items = $types.Where({ ($_.date -ge $dates[0]) -and ($_.date -le $dates[1]) })

        $items = $types.Where({ ($_.date -gt $dates[0]) -and ($_.date -le $dates[1]) })
                
        $sum = ($items | Measure-Object -Property value -Sum).Sum

        $str = if ($sum -eq $null) { '' } else { $sum.ToString('N') }

        Write-Host ('{0} {1,20} {2,30}' -f $dates[1], $str, (($items | ForEach-Object { $_.type }) -join ', '))

        loop ($dates | Select-Object -Skip 1)
    }
}

loop $dates