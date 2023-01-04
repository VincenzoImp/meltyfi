import { Nav } from 'react-bootstrap';

function MyNavbar() {
    return (
        <div>
            <Nav className='Nav' activeKey="/home">
                <Nav.Item className='NavItem'>
                    <Nav.Link className='NavLink' href="/home">Home</Nav.Link>
                </Nav.Item>
                <Nav.Item className='NavItem'>
                    <Nav.Link className='NavLink' href="/lotteries" >Lotteries</Nav.Link>
                </Nav.Item>
                <Nav.Item className='NavItem'>
                    <Nav.Link className='NavLink' href="/profile" >Profile</Nav.Link>
                </Nav.Item>
                <Nav.Item className='NavItem'>
                    <Nav.Link className='NavLink' href="https://github.com/VincenzoImp/MeltyFi" >GitHub</Nav.Link>
                </Nav.Item>
            </Nav>
        </div>
    );
}

export default MyNavbar;