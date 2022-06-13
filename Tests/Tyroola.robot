*** Settings ***
Documentation  This is some basic info about the whole suite
Library  SeleniumLibrary
Library  OperatingSystem
Library  String


*** Tasks ***
Download files from Popeye
    [Documentation]  Script to download files from Tyroola
    ${download directory}=  Join Path  ${OUTPUT DIR}  tyroola
    Create Directory  ${download directory}
    Empty Directory  ${download directory}

    # list of plugins to disable. disabling PDF Viewer is necessary so that PDFs are saved rather than displayed
    ${chrome options}=  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}=  Create Dictionary  download.default_directory=${download directory}  plugins.always_open_pdf_externally=${TRUE}
    Call Method  ${chrome options}  add_experimental_option  prefs  ${prefs}
    Create Webdriver  Chrome  chrome_options=${chrome options}


    Go To  ${popeye_url}/popeye/access/login?goTo=popeye/dashboard
    Maximize Browser Window

    Input Text  css=#username  ${username}
    Input Text  css=#password  ${password}
    Click Button  css=#cl-wrapper > div > div.block-flat > div:nth-child(2) > form > div.foot > button 
    Sleep  1s
    FOR  ${order}  IN  @{orders}
        Log  ${popeye_url}/order/detail/full/${order}
        Go To  ${popeye_url}/order/detail/full/${order}

        # Click Link  css=#invoices > tbody > tr > td:nth-child(1) > a
        ${invoices}=  Get WebElements  css=#invoices > tbody > tr > td:nth-child(1) > a
        ${length} =  Get Length  ${invoices}
        Run Keyword If  ${length} > 0  download_and_rename_pdfs  ${invoices}  ${order}
    END
    Close Browser


*** Keywords ***
download_and_rename_pdfs
    [Arguments]   ${invoices}  ${order}
    FOR  ${invoice}  IN  @{invoices}

        # get href
        ${url}=  Get Element Attribute  ${invoice}  href

        # split url
        ${invoice_num}=  Fetch From Right  ${url}  /

        # download file and wait to finish
        Click Link  ${invoice}
        Sleep  2s
        
        # rename file
        ${old_name}=  Join Path  ${OUTPUT DIR}  tyroola  ${invoice_num}.pdf
        ${new_name}=  Join Path  ${OUTPUT DIR}  tyroola  ${order}-inv_${invoice_num}.pdf
        Move File  ${old_name}  ${new_name}

        Sleep  1s
    END