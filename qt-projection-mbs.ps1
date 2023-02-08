
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

$rate = 2.75 / 3.32 # Jan / Dec    8.82

$month = '2023-02-'

$dates = @(
    '2023-02-01'
    '2023-02-08'
    '2023-02-15'
    '2023-02-22'
    '2023-03-01'
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
# Nov dates for Dec report

# $gnma_i_change  = $rate * (get-change 'GNMA I '  '2022-11-09' '2022-11-16')
# $gld_change     = $rate * (get-change 'FHLMCGLD' '2022-11-09' '2022-11-16')
# $gnma_ii_change = $rate * (get-change 'GNMA II'  '2022-11-16' '2022-11-23')
# $umbs_change    = $rate * (get-change 'UMBS'     '2022-11-23' '2022-11-30')
# ----------------------------------------------------------------------
# Dec dates for Jan report

# $gnma_i_change  = $rate * (get-change 'GNMA I '  '2022-12-14' '2022-12-21')
# $gld_change     = $rate * (get-change 'FHLMCGLD' '2022-12-14' '2022-12-21')
# $gnma_ii_change = $rate * (get-change 'GNMA II'  '2022-12-14' '2022-12-21')
# $umbs_change    = $rate * (get-change 'UMBS'     '2022-12-21' '2022-12-28')
# ----------------------------------------------------------------------
# Jan dates for Feb report

$gnma_i_change_  = (get-change 'GNMA I '  '2023-01-04' '2023-02-01')
$gld_change_     = (get-change 'FHLMCGLD' '2023-01-04' '2023-02-01')
$gnma_ii_change_ = (get-change 'GNMA II'  '2023-01-04' '2023-02-01')
$umbs_change_    = (get-change 'UMBS'     '2023-01-04' '2023-02-01')

$total = $umbs_change_ + $gnma_i_change_ + $gld_change_ + $gnma_ii_change_

function calc-new ($val)
{
    $reg = 5000000000 * $val / $total * -1 # regular payment portion

    $pre = $val - $reg                     # pre-payment portion

    $reg + $rate * $pre
}

$gnma_i_change  = calc-new $gnma_i_change_
$gld_change     = calc-new $gld_change_
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

Write-Host ('rate: {0:N}' -f $rate) -ForegroundColor Yellow
Write-Host

# 'UMBS          : {0,20}' -f ($umbs_change                                                 ).ToString('N') 
# 'GNMA I + GOLD : {0,20}' -f ($gnma_i_change + $gld_change                                 ).ToString('N') 
# 'GNMA II       : {0,20}' -f ($gnma_ii_change                                              ).ToString('N')               
# 'TOTAL         : {0,20}' -f ($umbs_change + $gnma_i_change + $gld_change + $gnma_ii_change).ToString('N')

          # UMBS          :   -10,039,438,836.07    -7,980,265,720.03    -3,429,278,977.61
# Write-Host '                               TOTAL           PREPAYMENT              REGULAR'
# 'UMBS          : {0,20} {1,20:N} {2,20:N}' -f ($umbs_change                                                 ).ToString('N'), (calc-pre $umbs_change_),                    (calc-reg $umbs_change_)
# 'GNMA I + GOLD : {0,20} {1,20:N} {2,20:N}' -f ($gnma_i_change + $gld_change                                 ).ToString('N'), (calc-pre ($gnma_i_change_ + $gld_change_)), (calc-reg ($gnma_i_change_ + $gld_change_))
# 'GNMA II       : {0,20} {1,20:N} {2,20:N}' -f ($gnma_ii_change                                              ).ToString('N'), (calc-pre $gnma_ii_change_),                 (calc-reg $gnma_ii_change_)
# 'TOTAL         : {0,20}' -f ($umbs_change + $gnma_i_change + $gld_change + $gnma_ii_change).ToString('N')



#           UMBS    :   -10,039,438,836.07    -6,610,159,858.45    -3,429,278,977.61
Write-Host '                         TOTAL           PREPAYMENT              REGULAR'
'UMBS    : {0,20} {1,20:N} {2,20:N}' -f ($umbs_change   ).ToString('N'), (calc-pre $umbs_change_),    (calc-reg $umbs_change_)
'GOLD    : {0,20} {1,20:N} {2,20:N}' -f ($gld_change    ).ToString('N'), (calc-pre $gld_change_),     (calc-reg $gld_change_)
'GNMA I  : {0,20} {1,20:N} {2,20:N}' -f ($gnma_i_change ).ToString('N'), (calc-pre $gnma_i_change_),  (calc-reg $gnma_i_change_)
'GNMA II : {0,20} {1,20:N} {2,20:N}' -f ($gnma_ii_change).ToString('N'), (calc-pre $gnma_ii_change_), (calc-reg $gnma_ii_change_)
'TOTAL   : {0,20}' -f ($umbs_change + $gnma_i_change + $gld_change + $gnma_ii_change).ToString('N')



#           UMBS    :   -10,039,438,836.07    -6,610,159,858.45    -3,429,278,977.61   -11,409,544,697.64
Write-Host '                         TOTAL           PREPAYMENT              REGULAR             PREVIOUS'
'UMBS    : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($umbs_change   ).ToString('N'), (calc-pre $umbs_change_),    (calc-reg $umbs_change_),    $umbs_change_
'GOLD    : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($gld_change    ).ToString('N'), (calc-pre $gld_change_),     (calc-reg $gld_change_),     $gld_change_
'GNMA I  : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($gnma_i_change ).ToString('N'), (calc-pre $gnma_i_change_),  (calc-reg $gnma_i_change_),  $gnma_i_change_
'GNMA II : {0,20} {1,20:N} {2,20:N} {3,20:N}' -f ($gnma_ii_change).ToString('N'), (calc-pre $gnma_ii_change_), (calc-reg $gnma_ii_change_), $gnma_ii_change_
'TOTAL   : {0,20}' -f ($umbs_change + $gnma_i_change + $gld_change + $gnma_ii_change).ToString('N')


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
    [pscustomobject]@{ date = $month + '15'; type = 'GNMA I + GOLD' ; value = $gnma_i_change + $gld_change }
    [pscustomobject]@{ date = $month + '20'; type = 'GNMA II'       ; value = $gnma_ii_change              }
    [pscustomobject]@{ date = $month + '25'; type = 'UMBS'          ; value = $umbs_change                 }
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