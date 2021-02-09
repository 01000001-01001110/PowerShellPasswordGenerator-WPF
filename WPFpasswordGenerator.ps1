<#
Created By: Alan Newingham
Name: WPFPasswordGenerator.ps1
Date: 02/09/2021

Create a WPF that generates passwords so I stop using https://passwordsgenerator.net/
#>

Add-Type -AssemblyName PresentationCore, PresentationFramework
$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="MainWindow"
        Height="282"
        Width="252"
        WindowStyle="None"
        ResizeMode="CanResize"
        AllowsTransparency="True"
        WindowStartupLocation="CenterScreen"
        Background="#167D7F"
        Foreground="#167D7F"
        FontFamily="Century Gothic"
        FontSize="14"
        Opacity="1" >
    <Window.Resources>
        <Style x:Key="MyButton" TargetType="Button">
            <Setter Property="OverridesDefaultStyle" Value="True" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" BorderThickness="1" BorderBrush="#98D7C2" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Opacity" Value="0.8" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="Gray"  />
        </Style>
    </Window.Resources>
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Grid Height="30" HorizontalAlignment="Stretch" VerticalAlignment="Top" Background="#29A0B1">
            <StackPanel Orientation="Horizontal">
                <Button Name="close_btn" Foreground="#98D7C2" Height="20" Width="20" Background="Transparent" Content="X" FontSize="14" Margin="10,0,0,0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <Button Name="minimize_btn" Foreground="#98D7C2" Height="20" Width="20" Background="Transparent" Content="-" FontSize="14" Margin="2 0 0 0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <TextBlock Text="Password Gen" Foreground="#98D7C2" VerticalAlignment="Center" Margin="100,6" />
            </StackPanel>
        </Grid>
        <CheckBox Name="symbols_chk" Foreground="Azure" Content="Include Symbols" HorizontalAlignment="Left" Margin="9,61,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="numbers_chk" Foreground="Azure" Content="Include Numbers" HorizontalAlignment="Left" Margin="9,77,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="lower_chk" Foreground="Azure" Content="Include Lowercase" HorizontalAlignment="Left" Margin="9,91,0,0" VerticalAlignment="Top" />
        <CheckBox Name="upper_chk" Foreground="Azure" Content="Include Uppercase" HorizontalAlignment="Left" Margin="9,106,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="similar_chk" Foreground="Azure" Content="Exclude Similar Characters" HorizontalAlignment="Left" Margin="9,122,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="dup_chk" Foreground="Azure" Content="No Duplicate Characters" HorizontalAlignment="Left" Margin="9,138,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="seq_chk" Foreground="Azure" Content="Non-Sequential" HorizontalAlignment="Left" Margin="9,154,0,0" VerticalAlignment="Top"/>
        <TextBox  Foreground="Azure" Name="text_bx" HorizontalAlignment="Left" Height="23" Margin="129,38,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="114"/>
        <TextBlock Foreground="Azure" HorizontalAlignment="Left" Margin="9,42,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Text="Password Length"/>
        <TextBox Foreground="Azure" ScrollViewer.VerticalScrollBarVisibility="Auto" Name="text_box" FontFamily="Consolas" HorizontalAlignment="Left" Margin="8,175,0,25" TextWrapping="Wrap" Width="237"/>
        <Button Name="btn_gen" Background="Transparent" Foreground="#98D7C2" Content="Generate" HorizontalAlignment="Left" Margin="169,153,0,0" VerticalAlignment="Top" Width="75" Style="{StaticResource MyButton}"/>
        <TextBlock HorizontalAlignment="Left" Margin="57,261,0,0"  Foreground="#98D7C2" TextWrapping="Wrap" VerticalAlignment="Top" Text="By Alan Newingham"/>
    </Grid>
</Window>


"@


#-------------------------------------------------------------#
#                      Window Function                        #
#-------------------------------------------------------------#
$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

#-------------------------------------------------------------#
#                  Define Window Move                         #
#-------------------------------------------------------------#

#Click and Drag WPF window without title bar (ChromeTab or whatever it is called)
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})

#-------------------------------------------------------------#
#                   Function Hide Console Window              #
#-------------------------------------------------------------#
function Show-Console
{
    param ([Switch]$Show,[Switch]$Hide)
    if (-not ("Console.Window" -as [type])) { 

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }

    if ($Show)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()

        # Hide = 0,
        # ShowNormal = 1,
        # ShowMinimized = 2,
        # ShowMaximized = 3,
        # Maximize = 3,
        # ShowNormalNoActivate = 4,
        # Show = 5,
        # Minimize = 6,
        # ShowMinNoActivate = 7,
        # ShowNoActivate = 8,
        # Restore = 9,
        # ShowDefault = 10,
        # ForceMinimized = 11

        $null = [Console.Window]::ShowWindow($consolePtr, 5)
    }

    if ($Hide)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        #0 hide
        $null = [Console.Window]::ShowWindow($consolePtr, 0)
    }
}

Show-Console -Hide


#-------------------------------------------------------------#
#                      Define Buttons                         #
#-------------------------------------------------------------#

#Custom Close Button
$close_btn.add_Click({
    $Window.Close();
})
#Custom Minimize Button
$minimize_btn.Add_Click({
    $Window.WindowState = 'Minimized'
})

#Custom Minimize Button
$btn_gen.Add_Click({

    #-------------------------------------------------------------#
    #            Define IF's to generate password                 #
    #-------------------------------------------------------------#

    Write-host $text_bx.Text
    $num = $text_bx.Text
    $fun = [int]$num
    if($symbols_chk.isChecked) {
        #Include Symbols
        $symbols = @('!','@','#','$','%','^','&','*','(',')','-','_','+','=','{','}','|',']','[',':',';')
        
    } else {
        #
    }
    if($numbers_chk.isChecked) {
        #Include Symbols
        $numbers = @('1','2','3','4','6','5','9','7','8','0')
        
    } else {
        #
    }
    if($lower_chk.isChecked) {
        #Include Lowercase Letters
        $lowercase = @('a','b','c','d','e','g','f','h','j','i','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')
    }
    else {
        #
    }
    if($upper_chk.isChecked) {
       #Include Uppercase Letters
       $uppercase = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
    } else {
        #
    }
    if($similar_chk.isChecked) {
        #Do Not Include Similar Characters

            #-------------------------------------------------------------#
            #            Define how simiar is different                   #
            #-------------------------------------------------------------#

        if($symbols_chk.isChecked) {
            #Include Symbols
            $symbols = @('@','#','$','%','^','&','*','(',')','-','_','+','=','{','}',']','[',':',';') 
        } else {
            #
        }
        if($numbers_chk.isChecked) {
            #Include Symbols
            $numbers = @('3','4','6','5','9','7','8')
            
        } else {
            #
        }
        if($lower_chk.isChecked) {
            #Include Lowercase Letters
            $lowercase = @('a','b','c','d','e','g','f','h','j','k','l','m','n','p','q','r','s','t','u','v','w','x','y')
        }
        else {
            #
        }
        if($upper_chk.isChecked) {
           #Include Uppercase Letters
           $uppercase = @('A','B','C','D','E','F','G','H','J','K','L','M','N','P','Q','R','S','T','U','V','W','X','Y')
        } else {
            #
        }
    } else {
        #
    }
    
        #-------------------------------------------------------------#
        #            Combine all variables into $last variable        #
        #-------------------------------------------------------------#

    $last = $symbols+$lowercase+$numbers+$uppercase
    

        #-------------------------------------------------------------#
        #            Define removing duplicates                       #
        #-------------------------------------------------------------#

    if($dup_chk.isChecked) {
        #Check for Duplicates and Remove
        $lastDup = $last
        $lastDup | Sort-Object -Unique
        $last = $lastDup
    } else {
        #
    }

        #-------------------------------------------------------------#
        #            define looking for sequential                    #
        #-------------------------------------------------------------#

    if($seq_chk.isChecked) {
        #Check for Sequential and Remove
        $lastSeq = $last | Select-Object –unique
        Compare-object –referenceobject $lastSeq –differenceobject $last
        $last = $lastSeq
    } else {
        #
    }

        #-------------------------------------------------------------#
        #            DLet's finish this and output for the user       #
        #-------------------------------------------------------------#

    $final = $last | get-random -count $fun
    $final = [system.String]::Join("", $final)
    $text_box.Text += "Your new password:"
    $text_box.Text += "`n"
    $text_box.Text += [string]$final
    $text_box.Text += "`n`n"
})

#-------------------------------------------------------------#
#                   Define Conditionals                       #
#-------------------------------------------------------------#

#Show Window, without this, the script will never initialize the OSD of the WPF elements.
$Window.ShowDialog()